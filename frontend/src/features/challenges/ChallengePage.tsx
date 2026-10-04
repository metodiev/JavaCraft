import { useQuery } from "@tanstack/react-query";
import Editor from "@monaco-editor/react";
import {
  AlertTriangle,
  ArrowLeft,
  Check,
  ChevronDown,
  CircleHelp,
  Clock3,
  FileCode2,
  FlaskConical,
  LockKeyhole,
  Play,
  Send,
  Shield,
  Terminal,
} from "lucide-react";
import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { QueryState } from "../../components/QueryState";
import { api } from "../../lib/api";

export function ChallengePage() {
  const { slug = "" } = useParams();
  const { data, isLoading, error } = useQuery({
    queryKey: ["challenge", slug],
    queryFn: ({ signal }) => api.challenge(slug, signal),
  });
  const [source, setSource] = useState<string | undefined>();
  const [showRunNotice, setShowRunNotice] = useState(false);

  return (
    <QueryState isLoading={isLoading} error={error}>
      {data && (
        <div className="challenge-page">
          <div className="challenge-toolbar">
            <Link className="back-link" to="/">
              <ArrowLeft size={14} /> Workspace
            </Link>
            <div className="challenge-toolbar-center">
              <span className="challenge-breadcrumb">CHALLENGES</span>
              <span>/</span>
              <strong>{data.title}</strong>
            </div>
            <div className="challenge-toolbar-right">
              <span className="save-status">Unsaved draft</span>
              <span className="avatar-mini">AM</span>
            </div>
          </div>
          <div className="challenge-layout">
            <aside className="challenge-brief">
              <div className="challenge-label">
                <span className="difficulty-dot" /> {data.level.toUpperCase()}{" "}
                <span>·</span> {data.category.toUpperCase()}
              </div>
              <h1>{data.title}</h1>
              <div className="challenge-tabs">
                <button className="challenge-tab active">
                  <FileCode2 size={14} /> Brief
                </button>
                <button className="challenge-tab">
                  <FlaskConical size={14} /> Tests
                </button>
              </div>
              <div className="brief-scroll">
                <div className="challenge-section">
                  <div className="section-kicker">THE SITUATION</div>
                  <p>{data.description}</p>
                </div>
                <div className="challenge-section">
                  <div className="section-kicker">ACCEPTANCE CRITERIA</div>
                  <ul className="criteria-list">
                    {data.requirements.map((item) => (
                      <li key={item}>
                        <span>
                          <Check size={11} />
                        </span>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="challenge-section">
                  <div className="section-kicker">SKILLS IN PLAY</div>
                  <div className="tag-row">
                    {data.skills.map((skill) => (
                      <span className="skill-tag" key={skill}>
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="challenge-callout">
                  <CircleHelp size={15} />
                  <div>
                    <strong>Think before you code</strong>
                    <p>What must be atomic if two requests arrive at the same time?</p>
                    <button disabled>
                      Ask your mentor <ChevronDown size={12} />
                    </button>
                  </div>
                </div>
                <div className="hidden-tests-note">
                  <LockKeyhole size={13} />
                  <span>Hidden tests are private and only run inside the sandbox.</span>
                </div>
              </div>
            </aside>
            <section className="editor-area">
              <div className="editor-topbar">
                <div className="file-tab">
                  <FileCode2 size={14} />
                  <span>PaymentService.java</span>
                  <span className="unsaved-dot" />
                </div>
                <div className="editor-tools">
                  <span>
                    <Shield size={13} /> Sandbox planned
                  </span>
                  <button disabled title="Editor settings coming soon">
                    <ChevronDown size={14} />
                  </button>
                </div>
              </div>
              <div className="monaco-wrap">
                <Editor
                  height="100%"
                  language="java"
                  theme="vs-dark"
                  value={source ?? data.starterCode}
                  onChange={setSource}
                  options={{
                    minimap: { enabled: false },
                    fontSize: 13,
                    lineHeight: 21,
                    padding: { top: 18 },
                    scrollBeyondLastLine: false,
                    automaticLayout: true,
                    tabSize: 4,
                    wordWrap: "on",
                    renderLineHighlight: "all",
                    overviewRulerBorder: false,
                    scrollbar: { verticalScrollbarSize: 8, horizontalScrollbarSize: 8 },
                    guides: { indentation: true },
                    fontFamily: "'SFMono-Regular', Consolas, 'Liberation Mono', monospace",
                  }}
                />
              </div>
              <div className="output-panel">
                <div className="output-top">
                  <div className="output-heading">
                    <Terminal size={14} />
                    <strong>OUTPUT</strong>
                    <span className="output-divider">/</span>
                    <span>Test results</span>
                  </div>
                  <div className="output-actions">
                    <span>
                      <Clock3 size={12} /> 0.0s
                    </span>
                    <ChevronDown size={14} />
                  </div>
                </div>
                <div className={`output-body${showRunNotice ? " output-notice" : ""}`}>
                  {showRunNotice ? (
                    <>
                      <AlertTriangle size={15} />
                      <div>
                        <strong>Sandbox execution is not available yet.</strong>
                        <p>
                          Your code was not sent or executed. Test runs will be enabled when
                          the isolated worker and resource limits are in place.
                        </p>
                      </div>
                    </>
                  ) : (
                    <>
                      <span className="terminal-prompt">›</span>
                      <span>
                        Your workspace is ready. Run tests when you&apos;re ready to see what
                        holds up.
                      </span>
                    </>
                  )}
                </div>
              </div>
              <div className="editor-footer">
                <span>
                  <span className="footer-dot" /> Java 21 <i /> UTF-8 <i /> LF
                </span>
                <div className="editor-buttons">
                  <button className="hint-button" disabled title="Hints are coming soon">
                    <CircleHelp size={14} /> Get a hint
                  </button>
                  <button className="run-button" onClick={() => setShowRunNotice(true)}>
                    <Play size={13} fill="currentColor" /> Run tests
                  </button>
                  <button className="submit-button" onClick={() => setShowRunNotice(true)}>
                    <Send size={13} /> Submit
                  </button>
                </div>
              </div>
            </section>
          </div>
        </div>
      )}
    </QueryState>
  );
}
