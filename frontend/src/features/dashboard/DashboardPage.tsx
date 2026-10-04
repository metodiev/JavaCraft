import { useQuery } from "@tanstack/react-query";
import {
  ArrowRight,
  ArrowUpRight,
  BookOpen,
  Check,
  ChevronRight,
  Clock3,
  Code2,
  Flame,
  GitBranch,
  LockKeyhole,
  Sparkles,
  Target,
  Trophy,
  Zap,
} from "lucide-react";
import type { ReactNode } from "react";
import { Link } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

const skillColors = ["#d0f56c", "#82dbbc", "#b1a3ff", "#6e9fff"];

export function DashboardPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["catalog"],
    queryFn: ({ signal }) => api.catalog(signal),
  });

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="dashboard-page">
          <div className="welcome-row">
            <div>
              <div className="eyebrow">
                <span className="eyebrow-line" />
                SAMPLE WORKSPACE
              </div>
              <h1>
                Build things that <span>hold up.</span>
              </h1>
              <p className="page-subtitle">A little better at engineering, every day.</p>
            </div>
            <div className="streak-pill">
              <Flame size={15} fill="currentColor" />
              <strong>4</strong>
              <span>day streak</span>
            </div>
          </div>

          <section className="hero-grid">
            <article className="level-card">
              <div className="card-overline">
                <span className="level-badge">
                  <span /> YOUR CURRENT LEVEL
                </span>
                <span className="card-muted">LEVEL 02 / 06</span>
              </div>
              <div className="level-heading">
                <div>
                  <h2>{data.currentLevel}</h2>
                  <p>You're building a solid foundation.</p>
                </div>
                <div className="level-emblem">
                  <Code2 size={24} />
                </div>
              </div>
              <div className="progress-label">
                <span>Progress to {data.nextLevel}</span>
                <strong>
                  {data.progressPercent}
                  <small>%</small>
                </strong>
              </div>
              <div className="progress-track">
                <div style={{ width: `${data.progressPercent}%` }} />
              </div>
              <div className="level-foot">
                <span>
                  <Sparkles size={13} /> 3 skills trending up
                </span>
                <Link to="/learning-path">
                  View your path <ArrowRight size={13} />
                </Link>
              </div>
              <div className="level-watermark">02</div>
            </article>

            <article className="focus-card">
              <div className="focus-top">
                <div className="focus-icon">
                  <Target size={17} />
                </div>
                <span className="focus-label">TODAY'S FOCUS</span>
                <span className="focus-time">
                  <Clock3 size={12} /> ~25 min
                </span>
              </div>
              <div className="focus-content">
                <div className="focus-kicker">
                  CHALLENGE <span>·</span> {data.challenge.level.toUpperCase()}
                </div>
                <h3>{data.challenge.title}</h3>
                <p>{data.challenge.description}</p>
              </div>
              <Link className="focus-cta" to={`/challenges/${data.challenge.slug}`}>
                <span>Open challenge</span> <ArrowRight size={15} />
              </Link>
              <div className="focus-orbit orbit-one" />
              <div className="focus-orbit orbit-two" />
            </article>
          </section>

          <section className="metrics-grid">
            <MetricCard
              label="SKILLS IN PROGRESS"
              value="08"
              detail="+2 this week"
              icon={<GitBranch size={15} />}
              positive
            />
            <MetricCard
              label="TUTORIALS COMPLETED"
              value="12"
              detail="of 24 in your path"
              icon={<BookOpen size={15} />}
            />
            <MetricCard
              label="CHALLENGES SOLVED"
              value="06"
              detail="Best streak: 3"
              icon={<Zap size={15} />}
            />
            <MetricCard
              label="YOUR RANK"
              value="Rookie"
              detail="Top 35% this month"
              icon={<Trophy size={15} />}
            />
          </section>

          <div className="content-grid">
            <section className="panel skill-panel">
              <div className="section-heading">
                <div>
                  <div className="section-kicker">YOUR FOUNDATION</div>
                  <h2>Skills taking shape</h2>
                </div>
                <Link to="/learning-path" className="text-link">
                  Skill map <ArrowUpRight size={14} />
                </Link>
              </div>
              <div className="skill-list">
                {data.skills.map((skill, index) => (
                  <div className="skill-row" key={skill.name}>
                    <div
                      className="skill-icon"
                      style={{ color: skillColors[index % skillColors.length] }}
                    >
                      <Code2 size={15} />
                    </div>
                    <div className="skill-info">
                      <div className="skill-name">
                        {skill.name}
                        <span className="skill-trend">
                          <ArrowUpRight size={11} /> +{index === 0 ? "8" : "4"}%
                        </span>
                      </div>
                      <div className="skill-track">
                        <span
                          style={{
                            width: `${skill.percent}%`,
                            backgroundColor: skillColors[index % skillColors.length],
                          }}
                        />
                      </div>
                    </div>
                    <span className="skill-percent">
                      {skill.percent}
                      <small>%</small>
                    </span>
                  </div>
                ))}
              </div>
              <div className="skill-note">
                <Sparkles size={14} />
                <span>Practice beats perfection. Keep showing your work.</span>
              </div>
            </section>

            <section className="panel path-panel">
              <div className="section-heading">
                <div>
                  <div className="section-kicker">KEEP YOUR MOMENTUM</div>
                  <h2>Up next</h2>
                </div>
                <Link to="/tutorials" className="text-link">
                  All tutorials <ArrowUpRight size={14} />
                </Link>
              </div>
              <div className="upnext-list">
                {data.tutorials.map((tutorial, index) => (
                  <Link
                    to={`/tutorials/${tutorial.slug}`}
                    className={`upnext-item${tutorial.status === "locked" ? " locked" : ""}`}
                    key={tutorial.slug}
                  >
                    <div className={`upnext-marker marker-${tutorial.status}`}>
                      {tutorial.status === "completed" ? (
                        <Check size={13} />
                      ) : tutorial.status === "locked" ? (
                        <LockKeyhole size={12} />
                      ) : (
                        <span>0{index + 1}</span>
                      )}
                    </div>
                    <div className="upnext-copy">
                      <strong>{tutorial.title}</strong>
                      <span>
                        {tutorial.durationMinutes} min <i />{" "}
                        {tutorial.status.replace("_", " ")}
                      </span>
                    </div>
                    <ChevronRight size={15} className="upnext-chevron" />
                  </Link>
                ))}
              </div>
              <div className="path-footer">
                <span>
                  <Check size={12} /> 12 of 24 modules complete
                </span>
                <Link to="/learning-path">
                  View learning path <ArrowRight size={13} />
                </Link>
              </div>
            </section>
          </div>

          <section className="bottom-quote">
            <div className="quote-mark">“</div>
            <div>
            <p>
              Good engineering isn't about knowing all the answers. It's about asking better
              questions.
            </p>
            <span>THE JAVACRAFT PRINCIPLE</span>
            </div>
          </section>
        </div>
      )}
    </QueryState>
  );
}

function MetricCard({
  label,
  value,
  detail,
  icon,
  positive = false,
}: {
  label: string;
  value: string;
  detail: string;
  icon: ReactNode;
  positive?: boolean;
}) {
  return (
    <article className="metric-card">
      <div className="metric-top">
        <span>{label}</span>
        <span className="metric-icon">{icon}</span>
      </div>
      <div className="metric-value">{value}</div>
      <div className={`metric-detail${positive ? " positive" : ""}`}>
        {positive && <ArrowUpRight size={12} />} {detail}
      </div>
    </article>
  );
}
