export interface TutorialSummary {
  slug: string;
  title: string;
  description: string;
  durationMinutes: number;
}

export interface Tutorial extends TutorialSummary {
  sections: Array<{ title: string; body: string; exampleCode: string }>;
}

export interface Challenge {
  slug: string;
  title: string;
  level: string;
  category: string;
  description: string;
  requirements: string[];
  starterCode: string;
  skills: string[];
}

export interface Catalog {
  tutorials: TutorialSummary[];
  challenge: Challenge;
}

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080/api/v1";

export interface Learner {
  id: string;
  email: string;
  displayName: string;
}

export interface LearnerProgress {
  currentTrack: string;
  completedTutorials: number;
  totalTutorials: number;
  progressPercent: number;
  tutorials: Array<{ slug: string; status: "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED" }>;
  skills: Array<{ slug: string; name: string; proficiency: number }>;
}

export interface ChallengeExecution {
  id: string;
  state:
    | "QUEUED"
    | "RUNNING"
    | "PASSED"
    | "FAILED"
    | "TIMED_OUT"
    | "RESOURCE_LIMITED"
    | "INFRASTRUCTURE_ERROR";
  durationMs: number | null;
  passed: number | null;
  total: number | null;
  summary: string | null;
  outputTruncated: boolean;
}

export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

let csrfToken: string | undefined;

async function loadCsrfToken(signal?: AbortSignal): Promise<void> {
  const response = await fetch(`${apiBaseUrl}/auth/csrf`, {
    signal,
    credentials: "include",
  });
  if (!response.ok) {
    throw new ApiError(`JavaCraft API returned ${response.status} for /auth/csrf`, response.status);
  }
  const body = (await response.json()) as { token: string };
  csrfToken = body.token;
}

async function request<T>(
  path: string,
  options: {
    method?: string;
    body?: unknown;
    signal?: AbortSignal;
    headers?: HeadersInit;
  } = {},
): Promise<T> {
  const method = options.method ?? "GET";
  const headers = new Headers(options.headers);
  if (options.body !== undefined) {
    headers.set("Content-Type", "application/json");
  }
  if (!["GET", "HEAD", "OPTIONS"].includes(method)) {
    await loadCsrfToken(options.signal);
    if (!csrfToken) throw new Error("The CSRF token could not be loaded");
    headers.set("X-XSRF-TOKEN", csrfToken);
  }
  const response = await fetch(`${apiBaseUrl}${path}`, {
    method,
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
    signal: options.signal,
    credentials: "include",
  });
  if (!response.ok) {
    const payload = (await response.json().catch(() => null)) as {
      detail?: string;
      message?: string;
    } | null;
    throw new ApiError(
      payload?.detail ?? payload?.message ?? `JavaCraft API returned ${response.status} for ${path}`,
      response.status,
    );
  }
  if (response.status === 204) return undefined as T;
  return response.json() as Promise<T>;
}

export const api = {
  catalog: (signal?: AbortSignal) => request<Catalog>("/catalog", { signal }),
  tutorials: (signal?: AbortSignal) => request<TutorialSummary[]>("/tutorials", { signal }),
  tutorial: (slug: string, signal?: AbortSignal) =>
    request<Tutorial>(`/tutorials/${encodeURIComponent(slug)}`, { signal }),
  challenge: (slug: string, signal?: AbortSignal) =>
    request<Challenge>(`/challenges/${encodeURIComponent(slug)}`, { signal }),
  auth: {
    me: async (signal?: AbortSignal) => {
      await loadCsrfToken(signal);
      try {
        return await request<Learner>("/auth/me", { signal });
      } catch (error) {
        if (error instanceof ApiError && error.status === 401) return null;
        throw error;
      }
    },
    login: (email: string, password: string) =>
      request<Learner>("/auth/login", { method: "POST", body: { email, password } }),
    register: (displayName: string, email: string, password: string) =>
      request<Learner>("/auth/register", {
        method: "POST",
        body: { displayName, email, password },
      }),
    logout: () => request<void>("/auth/logout", { method: "POST" }),
  },
  progress: (signal?: AbortSignal) => request<LearnerProgress>("/me/progress", { signal }),
  updateTutorialProgress: (slug: string, status: "IN_PROGRESS" | "COMPLETED") =>
    request<LearnerProgress>(`/me/tutorials/${encodeURIComponent(slug)}/progress`, {
      method: "PUT",
      body: { status },
    }),
  runChallenge: (slug: string, source: string, idempotencyKey: string) =>
    request<ChallengeExecution>(`/challenges/${encodeURIComponent(slug)}/runs`, {
      method: "POST",
      body: { source },
      headers: { "Idempotency-Key": idempotencyKey },
    }),
  execution: (executionId: string, signal?: AbortSignal) =>
    request<ChallengeExecution>(`/executions/${encodeURIComponent(executionId)}`, { signal }),
};
