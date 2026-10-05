# Shared helpers for the JavaCraft lifecycle scripts on Windows.
# Dot-source this file from start.ps1, stop.ps1, and restart.ps1; do not run it directly.
# Compatible with Windows PowerShell 5.1 and PowerShell 7+.

function Write-JcError {
    param([Parameter(Mandatory)][string]$Message)
    [Console]::Error.WriteLine($Message)
}

# Runs a native command, capturing stdout separately from stderr. Windows
# PowerShell 5.1 turns redirected native stderr into a terminating error under
# $ErrorActionPreference = 'Stop', so probe commands go through this helper.
function Invoke-JcNative {
    param(
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string[]]$Arguments,
        [string]$InputText
    )
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        # Preference changes are scoped to this function.
        $ErrorActionPreference = 'Continue'
        if ($InputText) {
            $stdout = $InputText | & $Command @Arguments 2> $stderrFile
        } else {
            $stdout = & $Command @Arguments 2> $stderrFile
        }
        $exitCode = $LASTEXITCODE
        $joined = ($stdout | Out-String).Trim()
        return [pscustomobject]@{
            ExitCode = $exitCode
            StdOut   = $joined
        }
    } finally {
        Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-JcTargetOS {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) { return 'Windows' }
        if ($IsLinux) { return 'Linux' }
        return 'MacOS'
    }
    # Windows PowerShell only runs on Windows.
    return 'Windows'
}

function Test-JcHasCommand {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue)
}

function Assert-JcDocker {
    if (-not (Test-JcHasCommand 'docker')) {
        Write-JcError 'Docker is required but not installed, or not on PATH.'
        exit 1
    }
    $probe = Invoke-JcNative 'docker' @('info')
    if ($probe.ExitCode -ne 0) {
        Write-JcError 'The Docker daemon is not reachable. Start Docker, then retry.'
        exit 1
    }
}

# Resolve the Compose CLI once: prefer the plugin, fall back to the standalone binary.
function Get-JcComposeCli {
    $probe = Invoke-JcNative 'docker' @('compose', 'version')
    if ($probe.ExitCode -eq 0) {
        $script:JcComposeExe = 'docker'
        $script:JcComposeArgs = @('compose')
        return
    }
    if (Test-JcHasCommand 'docker-compose') {
        $script:JcComposeExe = 'docker-compose'
        $script:JcComposeArgs = @()
        return
    }
    Write-JcError 'Docker Compose is required but not installed.'
    exit 1
}

function Invoke-JcCompose {
    param([Parameter(Mandatory)][string[]]$Arguments)
    $all = $script:JcComposeArgs + $Arguments
    # Compose writes its status lines to stderr. Windows PowerShell 5.1 turns
    # unhandled native stderr into a terminating error under
    # $ErrorActionPreference = 'Stop', so run it with the preference scoped to
    # this function; the caller's preference is restored on return.
    $ErrorActionPreference = 'Continue'
    & $script:JcComposeExe @all
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        exit $exitCode
    }
}

function Test-JcColimaContext {
    if (-not (Test-JcHasCommand 'colima')) {
        return $false
    }
    $probe = Invoke-JcNative 'docker' @('context', 'show')
    return ($probe.StdOut -eq 'colima')
}

function Test-JcDaemonReportsRunsc {
    $probe = Invoke-JcNative 'docker' @('info', '--format', '{{json .Runtimes}}')
    return ($probe.StdOut -match '"runsc"')
}

function Test-JcIsDockerDesktop {
    $probe = Invoke-JcNative 'docker' @('info', '--format', '{{.OperatingSystem}}')
    return ($probe.StdOut -match 'Docker Desktop')
}

# Export the socket settings the worker container needs inside a Colima VM.
function Export-JcColimaSandboxEnv {
    if (-not $env:EXECUTION_DOCKER_GID) {
        $probe = Invoke-JcNative 'colima' @('ssh', '--', 'getent', 'group', 'docker')
        if ($probe.ExitCode -ne 0 -or -not $probe.StdOut) { return $false }
        $env:EXECUTION_DOCKER_GID = ($probe.StdOut -split ':')[2]
    }
    if (-not $env:EXECUTION_DOCKER_SOCKET) {
        $env:EXECUTION_DOCKER_SOCKET = '/var/run/docker.sock'
    }
    return $true
}

# Derive the worker socket settings for a local Linux daemon or, on hosts such as
# Windows, from the active Docker context when the group id is provided.
function Export-JcHostSandboxEnv {
    if ($env:EXECUTION_DOCKER_SOCKET -and $env:EXECUTION_DOCKER_GID) {
        return $true
    }
    if ((Get-JcTargetOS) -eq 'Linux') {
        $socket = ''
        if ($env:DOCKER_HOST) {
            if ($env:DOCKER_HOST -like 'unix://*') {
                $socket = ($env:DOCKER_HOST).Substring(7)
            } else {
                return $false
            }
        } else {
            $socket = '/var/run/docker.sock'
        }
        if (-not (Test-Path $socket)) { return $false }
        if (-not $env:EXECUTION_DOCKER_SOCKET) {
            $env:EXECUTION_DOCKER_SOCKET = $socket
        }
        if (-not $env:EXECUTION_DOCKER_GID) {
            $probe = Invoke-JcNative 'stat' @('-c', '%g', $socket)
            if ($probe.ExitCode -ne 0 -or -not $probe.StdOut) { return $false }
            $env:EXECUTION_DOCKER_GID = $probe.StdOut
        }
        return $true
    }
    if (-not $env:EXECUTION_DOCKER_SOCKET) {
        $probe = Invoke-JcNative 'docker' @('context', 'inspect', '--format', '{{.Endpoints.docker.Host}}')
        if ($probe.StdOut -like 'unix://*') {
            $env:EXECUTION_DOCKER_SOCKET = $probe.StdOut.Substring(7)
        }
    }
    # Windows cannot derive the remote docker group id; the caller supplies it when
    # running the worker against a WSL2 or remote Linux engine.
    return [bool]($env:EXECUTION_DOCKER_SOCKET -and $env:EXECUTION_DOCKER_GID)
}

# One-time gVisor setup inside the Colima VM; idempotent and best effort.
function Install-JcColimaRunsc {
    Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'apt-get', 'update', '-qq') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'env', 'DEBIAN_FRONTEND=noninteractive', 'apt-get', 'install', '-y', '-qq', 'ca-certificates', 'curl', 'gnupg') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sh', '-c', 'curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor --yes -o /usr/share/keyrings/gvisor-archive-keyring.gpg') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sh', '-c', 'arch=$(dpkg --print-architecture); echo deb [arch=$arch signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main | sudo tee /etc/apt/sources.list.d/gvisor.list >/dev/null') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'apt-get', 'update', '-qq') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'env', 'DEBIAN_FRONTEND=noninteractive', 'apt-get', 'install', '-y', '-qq', 'runsc') | Out-Null
    Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'systemctl', 'reload', 'docker') | Out-Null
}

function Test-JcColimaRunscInstalled {
    $probe = Invoke-JcNative 'colima' @('ssh', '--', 'sh', '-c', 'command -v runsc >/dev/null 2>&1')
    return ($probe.ExitCode -eq 0)
}

# Register the gVisor runtime with the VM's Docker daemon and reload it. Colima
# recreates /etc/docker/daemon.json from its own configuration whenever the VM
# boots, so the registration must be re-applied whenever it is missing.
function Register-JcColimaRunsc {
    $mergeScript = @'
import json
path = "/etc/docker/daemon.json"
try:
    with open(path) as handle:
        config = json.load(handle)
except FileNotFoundError:
    config = {}
config.setdefault("runtimes", {})["runsc"] = {"path": "/usr/bin/runsc"}
with open(path, "w") as handle:
    json.dump(config, handle, indent=2)
'@
    $merge = Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'python3', '-') -InputText $mergeScript
    if ($merge.ExitCode -ne 0) { return $false }
    $reload = Invoke-JcNative 'colima' @('ssh', '--', 'sudo', 'systemctl', 'reload', 'docker')
    return ($reload.ExitCode -eq 0)
}

function Test-JcColimaRunscReady {
    if (-not (Test-JcDaemonReportsRunsc)) { return $false }
    return (Test-JcColimaRunscInstalled)
}

# Install gVisor when missing, keep its Docker registration current, and wait
# until the VM reports it as ready.
function Ensure-JcColimaRunsc {
    if (-not (Test-JcColimaRunscReady)) {
        if (-not (Test-JcColimaRunscInstalled)) {
            Write-Host 'JavaCraft: installing the gVisor sandbox runtime (runsc) in the Colima VM, one time only...'
            Install-JcColimaRunsc
        }
        if (-not (Test-JcDaemonReportsRunsc)) {
            Write-Host 'JavaCraft: registering the gVisor runtime with the Docker daemon in the Colima VM...'
            Register-JcColimaRunsc | Out-Null
        }
    }
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        if (Test-JcColimaRunscReady) { return $true }
        Start-Sleep -Seconds 1
    }
    return $false
}

# Decide whether the execution worker should start, exporting its sandbox settings
# when it does. Honors ENABLE_EXECUTION_WORKER=true|false; anything else (or unset)
# enables the worker automatically whenever a gVisor sandbox can be provided.
function Resolve-JcWorker {
    $mode = 'auto'
    if ($env:ENABLE_EXECUTION_WORKER -eq 'true') { $mode = 'true' }
    if ($env:ENABLE_EXECUTION_WORKER -eq 'false') { $mode = 'false' }
    if ($mode -eq 'false') {
        return $false
    }

    $reason = ''
    $worker = $false
    if (Test-JcColimaContext) {
        if ((Ensure-JcColimaRunsc) -and (Export-JcColimaSandboxEnv)) {
            $worker = $true
        } else {
            $reason = 'the automatic gVisor setup in the Colima VM did not succeed'
        }
    } elseif (Test-JcDaemonReportsRunsc) {
        if (Export-JcHostSandboxEnv) {
            $worker = $true
        } else {
            $reason = 'the gVisor runtime is present but the Docker socket settings could not be derived; set EXECUTION_DOCKER_SOCKET and EXECUTION_DOCKER_GID'
        }
    } elseif (Test-JcIsDockerDesktop) {
        $reason = 'Docker Desktop cannot run the gVisor sandbox'
    } else {
        $reason = 'this Docker host does not provide the gVisor sandbox'
    }

    if ($worker) {
        return $true
    }
    if ($mode -eq 'true') {
        Write-JcError ('JavaCraft: ENABLE_EXECUTION_WORKER=true but ' + $reason + ' (see README.md).')
        exit 1
    }
    Write-Host ('JavaCraft: challenge execution stays off because ' + $reason + ' (see README.md).')
    return $false
}
