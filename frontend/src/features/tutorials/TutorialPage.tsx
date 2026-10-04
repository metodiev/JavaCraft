import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, ArrowRight, BookOpen, Clock3 } from "lucide-react";
import { Link, useParams } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function TutorialPage() {
  const { slug = "" } = useParams();
  const { data, isLoading, error } = useQuery({
    queryKey: ["tutorial", slug],
    queryFn: ({ signal }) => api.tutorial(slug, signal),
  });

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="standard-page tutorial-detail">
          <Link className="back-link" to="/tutorials">
            <ArrowLeft size={14} /> All tutorials
          </Link>
          <div className="eyebrow">
            <span className="eyebrow-line" /> JAVA FUNDAMENTALS{" "}
            <span className="eyebrow-divider">/</span> TUTORIAL
          </div>
          <h1>
            {data.title.split(" ").slice(0, -1).join(" ")}{" "}
            <span>{data.title.split(" ").at(-1)}.</span>
          </h1>
          <p className="page-subtitle">{data.description}</p>
          <div className="lesson-meta">
            <span>
              <Clock3 size={14} /> {data.durationMinutes} min
            </span>
            <span>
              <BookOpen size={14} /> Interactive lesson
            </span>
          </div>
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
                  Choose data structures based on their guarantees and failure modes—not
                  only the happy-path speed.
                </span>
              </div>
            </article>
          ))}
          <Link className="primary-button" to="/challenges/payment-race-condition">
            Apply it in a challenge <ArrowRight size={15} />
          </Link>
        </div>
      )}
    </QueryState>
  );
}
