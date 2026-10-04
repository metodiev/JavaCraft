import { useQuery } from "@tanstack/react-query";
import { ArrowRight, BookOpen, Clock3, Search } from "lucide-react";
import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function TutorialsPage() {
  const [level, setLevel] = useState("All levels");
  const [search, setSearch] = useState("");
  const { data, isLoading, error } = useQuery({
    queryKey: ["tutorials"],
    queryFn: ({ signal }) => api.tutorials(signal),
  });
  const filteredTutorials = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();
    return (data ?? []).filter((tutorial) =>
      (level === "All levels" || tutorial.level === level) &&
      (!normalizedSearch ||
        `${tutorial.title} ${tutorial.description}`.toLowerCase().includes(normalizedSearch)),
    );
  }, [data, level, search]);

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
          <div className="catalog-filters">
            <label className="catalog-search">
              <Search size={14} />
              <input
                aria-label="Search tutorials"
                placeholder="Search tutorials"
                value={search}
                onChange={(event) => setSearch(event.target.value)}
              />
            </label>
            <label>
              <span className="sr-only">Filter by level</span>
              <select aria-label="Filter by level" value={level} onChange={(event) => setLevel(event.target.value)}>
                {["All levels", "Junior", "Mid", "Senior", "Lead", "Principal"].map((option) => (
                  <option key={option}>{option}</option>
                ))}
              </select>
            </label>
          </div>
          <p className="catalog-result-count">
            Showing {filteredTutorials.length} of {data.length} tutorials
          </p>
          <div className="tutorial-grid">
            {filteredTutorials.map((tutorial, index) => (
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
                    <span className="status-chip">{tutorial.level}</span>
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
          {filteredTutorials.length === 0 && (
            <div className="panel catalog-empty">No tutorials match these filters.</div>
          )}
        </div>
      )}
    </QueryState>
  );
}
