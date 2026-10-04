import { useQuery } from "@tanstack/react-query";
import { ArrowRight, BookOpen, Check } from "lucide-react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function LearningPathPage() {
  const catalogQuery = useQuery({
    queryKey: ["catalog"],
    queryFn: ({ signal }) => api.catalog(signal),
  });
  const progressQuery = useQuery({
    queryKey: ["progress"],
    queryFn: ({ signal }) => api.progress(signal),
  });
  const data = catalogQuery.data;
  const progress = progressQuery.data;

  return (
    <QueryState
      isLoading={catalogQuery.isLoading || progressQuery.isLoading}
      error={catalogQuery.error ?? progressQuery.error}
    >
      {data && progress && (
        <div className="standard-page">
          <div className="eyebrow">
            <span className="eyebrow-line" /> YOUR ENGINEERING JOURNEY
          </div>
          <h1>
            The path to <span>better engineering.</span>
          </h1>
          <p className="page-subtitle">
            A skill-first journey. Every step earned by showing what you can do.
          </p>
          <section className="path-overview panel">
            <div>
              <div className="section-kicker">CURRENT TRACK</div>
              <h2>{progress.currentTrack}</h2>
              <p>
                Build the fundamentals. Learn to write Java that other engineers can trust.
              </p>
            </div>
            <div className="path-overview-progress">
              <strong>{progress.progressPercent}%</strong>
              <span>
                {progress.completedTutorials} of {progress.totalTutorials} modules complete
              </span>
              <div className="progress-track">
                <div style={{ width: `${progress.progressPercent}%` }} />
              </div>
            </div>
          </section>
          <div className="path-module-list">
            {data.tutorials.map((tutorial, index) => (
              <article className="path-module panel" key={tutorial.slug}>
                <div className={`path-module-status ${progress.tutorials.find((item) => item.slug === tutorial.slug)?.status.toLowerCase() ?? "not_started"}`}>
                  {progress.tutorials.find((item) => item.slug === tutorial.slug)?.status === "COMPLETED" ? (
                    <Check size={16} />
                  ) : (
                    <BookOpen size={16} />
                  )}
                </div>
                <div className="path-module-main">
                  <div className="section-kicker">
                    MODULE 0{index + 1} <span>·</span> {tutorial.durationMinutes} MIN
                  </div>
                  <h3>{tutorial.title}</h3>
                  <p>{tutorial.description}</p>
                </div>
                <Link className="secondary-button" to={`/tutorials/${tutorial.slug}`}>
                  Open module <ArrowRight size={14} />
                </Link>
              </article>
            ))}
          </div>
        </div>
      )}
    </QueryState>
  );
}
