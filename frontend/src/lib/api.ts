export interface TutorialSummary {
  slug: string;
  title: string;
  description: string;
  durationMinutes: number;
  status: "locked" | "available" | "in_progress" | "completed";
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
  currentLevel: string;
  nextLevel: string;
  progressPercent: number;
  skills: Array<{ name: string; percent: number }>;
  tutorials: TutorialSummary[];
  challenge: Challenge;
}

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080/api/v1";

async function request<T>(path: string, signal?: AbortSignal): Promise<T> {
  const response = await fetch(`${apiBaseUrl}${path}`, { signal });
  if (!response.ok) {
    throw new Error(`JavaCraft API returned ${response.status} for ${path}`);
  }
  return response.json() as Promise<T>;
}

export const api = {
  catalog: (signal?: AbortSignal) => request<Catalog>("/catalog", signal),
  tutorials: (signal?: AbortSignal) => request<TutorialSummary[]>("/tutorials", signal),
  tutorial: (slug: string, signal?: AbortSignal) =>
    request<Tutorial>(`/tutorials/${encodeURIComponent(slug)}`, signal),
  challenge: (slug: string, signal?: AbortSignal) =>
    request<Challenge>(`/challenges/${encodeURIComponent(slug)}`, signal),
};
