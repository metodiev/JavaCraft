import { useQuery } from "@tanstack/react-query";
import { ArrowRight, BookOpen, Clock3 } from "lucide-react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function TutorialsPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["tutorials"],
    queryFn: ({ signal }) => api.tutorials(signal),
  });

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="standard-page">
          <div className="eyebrow">
            <span className="eyebrow-line" /> THE ENGINEERING LIBRARY
          </div>
          <h1>
            Learn it. <span>Then use it.</span>
          </h1>
          <p className="page-subtitle">
            Short, focused lessons with the why behind the Java.
          </p>
          <div className="tutorial-grid">
            {data.map((tutorial, index) => (
              <Link
                to={`/tutorials/${tutorial.slug}`}
                className="tutorial-card panel"
                key={tutorial.slug}
              >
                <div className={`tutorial-art art-${index + 1}`}>
                  <BookOpen size={22} />
                  <span>0{index + 1}</span>
                </div>
                <div className="tutorial-card-body">
                  <div className="tutorial-meta">
                    <span className="status-chip">LEARNING MODULE</span>
                    <span>
                      <Clock3 size={12} /> {tutorial.durationMinutes} min
                    </span>
                  </div>
                  <h2>{tutorial.title}</h2>
                  <p>{tutorial.description}</p>
                  <div className="tutorial-card-link">
                    Open tutorial <ArrowRight size={14} />
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
    </QueryState>
  );
}
