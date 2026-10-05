import { useQuery } from "@tanstack/react-query";
import { ArrowRight, BookOpen, Clock3, Layers, Search } from "lucide-react";
import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api, type TutorialSummary } from "../../lib/api";

const ALL_SECTIONS = "All sections";

interface TutorialGroup {
  slug: string;
  name: string;
  description: string;
  tutorials: TutorialSummary[];
}

export function TutorialsPage() {
  const [level, setLevel] = useState("All levels");
  const [section, setSection] = useState(ALL_SECTIONS);
  const [search, setSearch] = useState("");
  const tutorialsQuery = useQuery({
    queryKey: ["tutorials"],
    queryFn: ({ signal }) => api.tutorials(signal),
  });
  const categoriesQuery = useQuery({
    queryKey: ["tutorialCategories"],
    queryFn: ({ signal }) => api.tutorialCategories(signal),
  });
  const data = tutorialsQuery.data;
  const categories = categoriesQuery.data;

  const filteredTutorials = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();
    return (data ?? []).filter(
      (tutorial) =>
        (level === "All levels" || tutorial.level === level) &&
        (section === ALL_SECTIONS || tutorial.categorySlug === section) &&
        (!normalizedSearch ||
          `${tutorial.title} ${tutorial.description}`.toLowerCase().includes(normalizedSearch)),
    );
  }, [data, level, section, search]);

  // Browse by section: each section renders with its own heading, description, and count so
  // the catalog reads as a set of subjects rather than one undifferentiated list.
  const groups = useMemo<TutorialGroup[]>(() => {
    const descriptions = new Map((categories ?? []).map((c) => [c.slug, c.description]));
    const order = new Map((categories ?? []).map((c, index) => [c.slug, index]));
    const grouped = new Map<string, TutorialGroup>();
    for (const tutorial of filteredTutorials) {
      const slug = tutorial.categorySlug ?? "other";
      const existing = grouped.get(slug);
      if (existing) {
        existing.tutorials.push(tutorial);
        continue;
      }
      grouped.set(slug, {
        slug,
        name: tutorial.categoryName ?? "Other",
        description: descriptions.get(slug) ?? "",
        tutorials: [tutorial],
      });
    }
    return [...grouped.values()].sort(
      (a, b) => (order.get(a.slug) ?? 999) - (order.get(b.slug) ?? 999),
    );
  }, [filteredTutorials, categories]);

  return (
    <QueryState
      isLoading={tutorialsQuery.isLoading || categoriesQuery.isLoading}
      error={tutorialsQuery.error ?? categoriesQuery.error}
    >
      {data && (
        <div className="standard-page">
          <div className="eyebrow">
            <span className="eyebrow-line" /> THE ENGINEERING LIBRARY
          </div>
          <h1>
            Learn it. <span>Then use it.</span>
          </h1>
          <p className="page-subtitle">
            Short, focused lessons with the why behind the Java, grouped by subject.
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
              <span className="sr-only">Filter by section</span>
              <select
                aria-label="Filter by section"
                value={section}
                onChange={(event) => setSection(event.target.value)}
              >
                <option>{ALL_SECTIONS}</option>
                {(categories ?? []).map((category) => (
                  <option key={category.slug} value={category.slug}>
                    {category.name} ({category.tutorialCount})
                  </option>
                ))}
              </select>
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
            {section === ALL_SECTIONS
              ? ` across ${groups.length} sections`
              : ` in ${categories?.find((c) => c.slug === section)?.name ?? section}`}
          </p>
          {groups.map((group) => (
            <section className="catalog-section" key={group.slug}>
              <header className="catalog-section-header">
                <div className="catalog-section-title">
                  <Layers size={16} />
                  <h2>{group.name}</h2>
                  <span className="catalog-section-count">{group.tutorials.length}</span>
                </div>
                {group.description && <p>{group.description}</p>}
              </header>
              <div className="tutorial-grid">
                {group.tutorials.map((tutorial, index) => (
                  <Link
                    to={`/tutorials/${tutorial.slug}`}
                    className="tutorial-card panel"
                    key={tutorial.slug}
                  >
                    <div className={`tutorial-art art-${(index % 12) + 1}`}>
                      <BookOpen size={22} />
                      <span>{String(index + 1).padStart(2, "0")}</span>
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
            </section>
          ))}
          {filteredTutorials.length === 0 && (
            <div className="panel catalog-empty">No tutorials match these filters.</div>
          )}
        </div>
      )}
    </QueryState>
  );
}
