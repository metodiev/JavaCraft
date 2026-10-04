import { useQuery } from "@tanstack/react-query";
import { ArrowRight, Code2, Search } from "lucide-react";
import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

const levels = ["All levels", "Junior", "Mid", "Senior", "Lead", "Principal"];

export function ChallengesPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["challenges"],
    queryFn: ({ signal }) => api.challenges(signal),
  });
  const [level, setLevel] = useState("All levels");
  const [category, setCategory] = useState("All categories");
  const [search, setSearch] = useState("");

  const categories = useMemo(
    () => ["All categories", ...new Set(data?.map((challenge) => challenge.category) ?? [])],
    [data],
  );
  const filteredChallenges = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();
    return (data ?? []).filter((challenge) => {
      return (
        (level === "All levels" || challenge.level === level) &&
        (category === "All categories" || challenge.category === category) &&
        (!normalizedSearch ||
          `${challenge.title} ${challenge.description} ${challenge.category}`
            .toLowerCase()
            .includes(normalizedSearch))
      );
    });
  }, [category, data, level, search]);

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="standard-page">
          <div className="eyebrow">
            <span className="eyebrow-line" /> PRACTICE BY LEVEL
          </div>
          <h1>
            Engineering <span>challenges.</span>
          </h1>
          <p className="page-subtitle">
            Build practical skills from your first Java methods through organization-wide
            architecture decisions.
          </p>
          <div className="catalog-filters">
            <label className="catalog-search">
              <Search size={14} />
              <input
                aria-label="Search challenges"
                placeholder="Search challenges"
                value={search}
                onChange={(event) => setSearch(event.target.value)}
              />
            </label>
            <label>
              <span className="sr-only">Filter by level</span>
              <select aria-label="Filter by level" value={level} onChange={(event) => setLevel(event.target.value)}>
                {levels.map((option) => <option key={option}>{option}</option>)}
              </select>
            </label>
            <label>
              <span className="sr-only">Filter by category</span>
              <select aria-label="Filter by category" value={category} onChange={(event) => setCategory(event.target.value)}>
                {categories.map((option) => <option key={option}>{option}</option>)}
              </select>
            </label>
          </div>
          <p className="catalog-result-count">
            Showing {filteredChallenges.length} of {data.length} challenges
          </p>
          {filteredChallenges.length > 0 ? (
            <div className="tutorial-grid">
              {filteredChallenges.map((challenge, index) => (
                <Link
                  to={`/challenges/${challenge.slug}`}
                  className="tutorial-card panel"
                  key={challenge.slug}
                >
                  <div className={`tutorial-art art-${(index % 6) + 1}`}>
                    <Code2 size={22} />
                    <span>{String(index + 1).padStart(2, "0")}</span>
                  </div>
                  <div className="tutorial-card-body">
                    <div className="tutorial-meta">
                      <span className="status-chip">{challenge.level}</span>
                      <span>{challenge.category}</span>
                    </div>
                    <h2>{challenge.title}</h2>
                    <p>{challenge.description}</p>
                    <div className="tutorial-card-link">
                      View challenge <ArrowRight size={14} />
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          ) : (
            <div className="panel catalog-empty">No challenges match these filters.</div>
          )}
        </div>
      )}
    </QueryState>
  );
}
