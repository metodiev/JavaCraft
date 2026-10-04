import {
  Activity,
  ArrowUpRight,
  BookOpen,
  Boxes,
  Code2,
  Command,
  LayoutDashboard,
  Lightbulb,
  PanelLeftClose,
  Search,
  Settings2,
  ShieldCheck,
  Sparkles,
  TerminalSquare,
} from "lucide-react";
import { NavLink, Outlet, useLocation } from "react-router-dom";

const navigation = [
  { to: "/", label: "Overview", icon: LayoutDashboard, end: true },
  { to: "/learning-path", label: "Learning path", icon: Boxes },
  { to: "/tutorials", label: "Tutorials", icon: BookOpen },
];

const pageTitles: Record<string, string> = {
  "/": "Overview",
  "/learning-path": "Learning path",
  "/tutorials": "Tutorials",
};

export function AppShell() {
  const { pathname } = useLocation();
  const pageTitle =
    pageTitles[pathname] ??
    (pathname.startsWith("/challenges/") ? "Challenge workspace" : "Tutorial");

  return (
    <div className="app-frame">
      <aside className="sidebar">
        <NavLink className="brand" to="/" aria-label="JavaCraft home">
          <span className="brand-mark">
            <Code2 size={19} strokeWidth={2.5} />
          </span>
          <span>
            java<span className="brand-light">craft</span>
          </span>
          <span className="brand-beta">BETA</span>
        </NavLink>
        <button className="workspace-picker">
          <span className="workspace-avatar">A</span>
          <span className="workspace-name">
            <strong>Alex Morgan</strong>
            <small>Personal workspace</small>
          </span>
          <PanelLeftClose size={15} />
        </button>

        <div className="nav-caption">LEARN</div>
        <nav className="side-nav" aria-label="Main navigation">
          {navigation.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}
            >
              <Icon size={17} />
              <span>{label}</span>
              {label === "Learning path" && <span className="nav-count">01</span>}
            </NavLink>
          ))}
          <NavLink
            to="/challenges/payment-race-condition"
            className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}
          >
            <TerminalSquare size={17} />
            <span>Challenges</span>
            <span className="nav-dot" />
          </NavLink>
        </nav>

        <div className="nav-caption nav-caption-spaced">YOUR WORK</div>
        <nav className="side-nav" aria-label="Your work">
          <button className="nav-item">
            <Activity size={17} />
            <span>Skill graph</span>
            <span className="soon-tag">SOON</span>
          </button>
          <button className="nav-item">
            <ShieldCheck size={17} />
            <span>Achievements</span>
          </button>
        </nav>

        <div className="sidebar-bottom">
          <div className="mentor-card">
            <div className="mentor-icon">
              <Sparkles size={16} />
            </div>
            <strong>Your engineering mentor</strong>
            <p>Good engineers ask better questions.</p>
            <button className="mentor-link" disabled>
              Meet your mentor <ArrowUpRight size={13} />
            </button>
            <span className="mentor-coming">COMING SOON</span>
          </div>
          <button className="nav-item">
            <Settings2 size={17} />
            <span>Settings</span>
          </button>
          <div className="sidebar-foot">
            <span className="status-pulse" />
            All systems operational <span>v0.1.0</span>
          </div>
        </div>
      </aside>

      <main className="main-area">
        <header className="topbar">
          <div className="breadcrumbs">
            <span>Workspace</span>
            <span className="crumb-slash">/</span>
            <strong>{pageTitle}</strong>
          </div>
          <div className="topbar-actions">
            <button className="search-trigger">
              <Search size={15} />
              <span>Search anything…</span>
              <kbd>
                <Command size={10} /> K
              </kbd>
            </button>
            <button className="icon-button" aria-label="Quick tips">
              <Lightbulb size={17} />
            </button>
            <div className="top-divider" />
            <button className="profile-button">
              <span className="profile-avatar">AM</span>
              <span className="profile-chevron">⌄</span>
            </button>
          </div>
        </header>
        <div className="page-content">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
