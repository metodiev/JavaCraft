import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, ArrowRight, BookOpen, Check, ClipboardCheck, Clock3, Layers } from "lucide-react";
import { Link, useParams } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function TutorialPage() {
  const { slug = "" } = useParams();
  const queryClient = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ["tutorial", slug],
    queryFn: ({ signal }) => api.tutorial(slug, signal),
  });
  const progressQuery = useQuery({
    queryKey: ["progress"],
    queryFn: ({ signal }) => api.progress(signal),
  });
  const updateProgress = useMutation({
    mutationFn: (status: "IN_PROGRESS" | "COMPLETED") =>
      api.updateTutorialProgress(slug, status),
    onSuccess: (progress) => queryClient.setQueryData(["progress"], progress),
  });
  const tutorialStatus = progressQuery.data?.tutorials.find((item) => item.slug === slug)?.status;

  return (
    <QueryState
      isLoading={isLoading || progressQuery.isLoading}
      error={error ?? progressQuery.error}
    >
      {data && (
        <div className="standard-page tutorial-detail">
          <Link className="back-link" to="/tutorials">
            <ArrowLeft size={14} /> All tutorials
          </Link>
          <div className="eyebrow">
            <span className="eyebrow-line" /> {data.level.toUpperCase()}{" "}
            <span className="eyebrow-divider">/</span> TUTORIAL
          </div>
          <h1>
            {data.title.split(" ").slice(0, -1).join(" ")}{" "}
            <span>{data.title.split(" ").at(-1)}.</span>
          </h1>
          {data.categoryName && (
            <div className="tutorial-section-tag">
              <Layers size={13} /> {data.categoryName}
            </div>
          )}
          <p className="page-subtitle">{data.description}</p>
          <div className="lesson-meta">
            <span>
              <Clock3 size={14} /> {data.durationMinutes} min
            </span>
            <span>
              <BookOpen size={14} /> Interactive lesson
            </span>
          </div>
          <div className="lesson-progress">
            <span>
              {tutorialStatus === "COMPLETED"
                ? "Completed"
                : tutorialStatus === "IN_PROGRESS"
                  ? "In progress"
                  : "Not started"}
            </span>
            <button
              className="secondary-button"
              disabled={tutorialStatus === "COMPLETED" || updateProgress.isPending}
              onClick={() => updateProgress.mutate("COMPLETED")}
            >
              {tutorialStatus === "COMPLETED" ? <Check size={14} /> : null}
              {tutorialStatus === "COMPLETED" ? "Completed" : "Mark complete"}
            </button>
          </div>
          {updateProgress.error && (
            <div className="inline-error" role="alert">
              {updateProgress.error.message}
            </div>
          )}
          {data.sections.map((section) => (
            <article className="lesson-section panel" key={section.title}>
              <div className="section-kicker">THE CONCEPT</div>
              <h2>{section.title}</h2>
              <p>{section.body}</p>
              <pre className="code-sample">
                <code>{section.exampleCode}</code>
              </pre>
              <div className="engineering-note">
                <strong>Engineering note</strong>
                <span>
                  Start with the behavior your callers need, then choose the smallest design
                  that makes that behavior safe and clear.
                </span>
              </div>
            </article>
          ))}
          <div className="tutorial-actions">
            {tutorialStatus !== "COMPLETED" && (
              <button
                className="primary-button"
                disabled={updateProgress.isPending}
                onClick={() => updateProgress.mutate("IN_PROGRESS")}
              >
                {updateProgress.isPending ? "Saving…" : "Save as in progress"}
              </button>
            )}
          </div>
          {data.challenges.length > 0 ? (
            <section className="tutorial-practice">
              <div className="tutorial-practice-header">
                <ClipboardCheck size={15} />
                <h2>Practise this lesson</h2>
                <span className="catalog-section-count">{data.challenges.length}</span>
              </div>
              <p>
                Runnable challenges that exercise the same ideas. Each one compiles and runs in
                the sandbox against public tests.
              </p>
              <div className="tutorial-practice-list">
                {data.challenges.map((challenge) => (
                  <Link
                    className="tutorial-practice-item panel"
                    to={`/challenges/${challenge.slug}`}
                    key={challenge.slug}
                  >
                    <div className="tutorial-practice-item-main">
                      <span className="status-chip">{challenge.level}</span>
                      <h3>{challenge.title}</h3>
                      <p>{challenge.description}</p>
                    </div>
                    <ArrowRight size={15} />
                  </Link>
                ))}
              </div>
            </section>
          ) : (
            <div className="tutorial-actions tutorial-actions-footer">
              <Link className="primary-button" to="/challenges">
                Browse all challenges <ArrowRight size={15} />
              </Link>
            </div>
          )}
        </div>
      )}
    </QueryState>
  );
}
