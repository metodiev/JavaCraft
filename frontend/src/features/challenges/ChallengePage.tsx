import { useMutation, useQuery } from "@tanstack/react-query";
import Editor from "@monaco-editor/react";
import {
  AlertTriangle,
  ArrowLeft,
  Check,
  ChevronDown,
  CircleHelp,
  Clock3,
  FileCode2,
  FlaskConical,
  LockKeyhole,
  Play,
  Send,
  Shield,
  Terminal,
} from "lucide-react";
import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { useAuth } from "../../app/AuthContext";
import { api } from "../../lib/api";

export function ChallengePage() {
  const { slug = "" } = useParams();
  const { learner } = useAuth();
  const { data, isLoading, error } = useQuery({
    queryKey: ["challenge", slug],
    queryFn: ({ signal }) => api.challenge(slug, signal),
  });
  const [source, setSource] = useState<string | undefined>();
  const [executionId, setExecutionId] = useState<string | null>(null);
  const run = useMutation({
    mutationFn: () => api.runChallenge(slug, source ?? data?.starterCode ?? "", crypto.randomUUID()),
    onMutate: () => setExecutionId(null),
    onSuccess: (execution) => setExecutionId(execution.id),
  });
  const execution = useQuery({
    queryKey: ["execution", executionId],
    queryFn: ({ signal }) => api.execution(executionId ?? "", signal),
    enabled: executionId !== null,
    refetchIntervalInBackground: true,
    refetchInterval: (query) => {
      const state = query.state.data?.state;
      return state === "QUEUED" || state === "RUNNING" ? 1_000 : false;
    },
  });
  const isRunning =
    run.isPending ||
    execution.data?.state === "QUEUED" ||
    execution.data?.state === "RUNNING";
  const runError = run.error ?? execution.error;
  const initials = learner?.displayName
    .split(/\s+/)
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="challenge-page">
          <div className="challenge-toolbar">
            <Link className="back-link" to="/">
              <ArrowLeft size={14} /> Workspace
            </Link>
            <div className="challenge-toolbar-center">
              <span className="challenge-breadcrumb">CHALLENGES</span>
              <span>/</span>
              <strong>{data.title}</strong>
            </div>
            <div className="challenge-toolbar-right">
              <span className="save-status">Unsaved draft</span>
              <span className="avatar-mini">{initials}</span>
            </div>
          </div>
          <div className="challenge-layout">
            <aside className="challenge-brief">
              <div className="challenge-label">
                <span className="difficulty-dot" /> {data.level.toUpperCase()}{" "}
                <span>·</span> {data.category.toUpperCase()}
              </div>
              <h1>{data.title}</h1>
              <div className="challenge-tabs">
                <button className="challenge-tab active">
                  <FileCode2 size={14} /> Brief
                </button>
                <button className="challenge-tab">
                  <FlaskConical size={14} /> Tests
                </button>
              </div>
              <div className="brief-scroll">
                <div className="challenge-section">
                  <div className="section-kicker">THE SITUATION</div>
                  <p>{data.description}</p>
                </div>
                <div className="challenge-section">
                  <div className="section-kicker">ACCEPTANCE CRITERIA</div>
                  <ul className="criteria-list">
                    {data.requirements.map((item) => (
                      <li key={item}>
                        <span>
                          <Check size={11} />
                        </span>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="challenge-section">
                  <div className="section-kicker">SKILLS IN PLAY</div>
                  <div className="tag-row">
                    {data.skills.map((skill) => (
                      <span className="skill-tag" key={skill}>
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="challenge-callout">
                  <CircleHelp size={15} />
                  <div>
                    <strong>Think before you code</strong>
                    <p>What must be atomic if two requests arrive at the same time?</p>
                    <button disabled>
                      Ask your mentor <ChevronDown size={12} />
                    </button>
                  </div>
                </div>
                <div className="hidden-tests-note">
                  <LockKeyhole size={13} />
                  <span>
                    {data.runnable
                      ? "Only public tests are enabled. Hidden-test grading is not available yet."
                      : "Challenge instructions are ready. Java execution is not enabled for this challenge yet."}
                  </span>
                </div>
              </div>
            </aside>
            <section className="editor-area">
              <div className="editor-topbar">
                <div className="file-tab">
                  <FileCode2 size={14} />
                  <span>{slug === "payment-race-condition" ? "PaymentService.java" : "Main.java"}</span>
                  <span className="unsaved-dot" />
                </div>
                <div className="editor-tools">
                  <span>
                    <Shield size={13} />{" "}
                    {data.runnable ? "gVisor sandbox required" : "Execution is not enabled for this challenge"}
                  </span>
                  <button disabled title="Editor settings coming soon">
                    <ChevronDown size={14} />
                  </button>
                </div>
              </div>
              <div className="monaco-wrap">
                <Editor
                  height="100%"
                  language="java"
                  theme="vs-dark"
                  value={source ?? data.starterCode}
                  onChange={setSource}
                  options={{
                    minimap: { enabled: false },
                    fontSize: 13,
                    lineHeight: 21,
                    padding: { top: 18 },
                    scrollBeyondLastLine: false,
                    automaticLayout: true,
                    tabSize: 4,
                    wordWrap: "on",
                    renderLineHighlight: "all",
                    overviewRulerBorder: false,
                    scrollbar: { verticalScrollbarSize: 8, horizontalScrollbarSize: 8 },
                    guides: { indentation: true },
                    fontFamily: "'SFMono-Regular', Consolas, 'Liberation Mono', monospace",
                  }}
                />
              </div>
              <div className="output-panel">
                <div className="output-top">
                  <div className="output-heading">
                    <Terminal size={14} />
                    <strong>OUTPUT</strong>
                    <span className="output-divider">/</span>
                    <span>Test results</span>
                  </div>
                  <div className="output-actions">
                    <span>
                      <Clock3 size={12} />{" "}
                      {execution.data?.durationMs === null || execution.data?.durationMs === undefined
                        ? "0.0s"
                        : `${(execution.data.durationMs / 1_000).toFixed(2)}s`}
                    </span>
                    <ChevronDown size={14} />
                  </div>
                </div>
                <div
                  className={`output-body${runError || execution.data?.state === "FAILED" ? " output-notice" : ""}`}
                  aria-live="polite"
                >
                  {runError ? (
                    <>
                      <AlertTriangle size={15} />
                      <div>
                        <strong>Could not run this challenge.</strong>
                        <p>{runError.message}</p>
                      </div>
                    </>
                  ) : isRunning ? (
                    <>
                      <Clock3 size={15} />
                      <span>
                        {execution.data?.state === "RUNNING"
                          ? "Running public tests in the isolated sandbox…"
                          : "Waiting for the isolated sandbox…"}
                      </span>
                    </>
                  ) : execution.data ? (
                    <>
                      {execution.data.state === "PASSED" ? (
                        <Check size={15} />
                      ) : (
                        <AlertTriangle size={15} />
                      )}
                      <div>
                        <strong style={{ whiteSpace: "pre-wrap" }}>
                          {execution.data.summary ?? execution.data.state}
                        </strong>
                        {execution.data.durationMs !== null && (
                          <p>Completed in {(execution.data.durationMs / 1_000).toFixed(2)}s.</p>
                        )}
                        {execution.data.outputTruncated && (
                          <p>Some output was truncated to protect the runner.</p>
                        )}
                      </div>
                    </>
                  ) : (
                    <>
                      <span className="terminal-prompt">›</span>
                      <span>
                        Your workspace is ready. Run tests when you&apos;re ready to see what
                        holds up.
                      </span>
                    </>
                  )}
                </div>
              </div>
              <div className="editor-footer">
                <span>
                  <span className="footer-dot" /> Java 21 <i /> UTF-8 <i /> LF
                </span>
                <div className="editor-buttons">
                  <button className="hint-button" disabled title="Hints are coming soon">
                    <CircleHelp size={14} /> Get a hint
                  </button>
                  <button
                    className="run-button"
                    onClick={() => run.mutate()}
                    disabled={isRunning || !data.runnable}
                    title={data.runnable ? undefined : "Execution adapter coming soon"}
                  >
                    <Play size={13} fill="currentColor" />{" "}
                    {isRunning ? "Running…" : data.runnable ? "Run public tests" : "Execution coming soon"}
                  </button>
                  <button
                    className="submit-button"
                    disabled
                    title="Hidden-test grading is not available yet"
                  >
                    <Send size={13} /> Submit
                  </button>
                </div>
              </div>
            </section>
          </div>
        </div>
      )}
    </QueryState>
  );
}
