import { useState, type FormEvent } from "react";
import { ArrowRight, Code2, LoaderCircle } from "lucide-react";
import { Link, Navigate, useLocation, useNavigate } from "react-router-dom";
import { ApiError } from "../../lib/api";
import { useAuth } from "../../app/AuthContext";

export function AuthPage({ mode }: { mode: "login" | "register" }) {
  const { learner, loading, login, register } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const isRegister = mode === "register";
  const destination = (location.state as { from?: string } | null)?.from ?? "/";

  if (loading) return <div className="auth-loading">Restoring your JavaCraft session…</div>;
  if (learner) return <Navigate to={destination} replace />;

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitting(true);
    setError("");
    try {
      if (isRegister) await register(displayName, email, password);
      else await login(email, password);
      navigate(destination, { replace: true });
    } catch (cause) {
      if (cause instanceof ApiError && cause.status === 409) {
        setError("An account with that email already exists. Try signing in instead.");
      } else if (cause instanceof ApiError && cause.status === 401) {
        setError("That email and password combination wasn’t recognized.");
      } else {
        setError(cause instanceof Error ? cause.message : "We couldn’t complete the request.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-page">
      <div className="auth-glow" />
      <div className="auth-card">
        <Link to="/" className="brand auth-brand" aria-label="JavaCraft">
          <span className="brand-mark"><Code2 size={19} strokeWidth={2.5} /></span>
          <span>java<span className="brand-light">craft</span></span>
        </Link>
        <div className="auth-eyebrow"><span className="eyebrow-line" /> YOUR ENGINEERING JOURNEY</div>
        <h1>{isRegister ? <>Start building<br /><span>things that hold up.</span></> : <>Welcome<br /><span>back to the workshop.</span></>}</h1>
        <p className="auth-subtitle">
          {isRegister
            ? "Create an account to keep your learning and progress."
            : "Sign in to pick up where your engineering left off."}
        </p>
        <form className="auth-form" onSubmit={handleSubmit}>
          {isRegister && (
            <label>
              <span>Your name</span>
              <input
                autoComplete="name"
                maxLength={80}
                required
                value={displayName}
                onChange={(event) => setDisplayName(event.target.value)}
                placeholder="Alex Morgan"
              />
            </label>
          )}
          <label>
            <span>Email address</span>
            <input
              autoComplete="email"
              maxLength={254}
              required
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="you@example.com"
            />
          </label>
          <label>
            <span>Password</span>
            <input
              autoComplete={isRegister ? "new-password" : "current-password"}
              minLength={isRegister ? 12 : 1}
              maxLength={128}
              required
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder={isRegister ? "At least 12 characters" : "Your password"}
            />
          </label>
          {error && <div className="auth-error" role="alert">{error}</div>}
          <button className="auth-submit" type="submit" disabled={submitting}>
            {submitting ? <LoaderCircle className="spin" size={16} /> : null}
            {isRegister ? "Create your account" : "Sign in"}
            {!submitting && <ArrowRight size={15} />}
          </button>
        </form>
        <div className="auth-switch">
          {isRegister ? "Already have an account?" : "New to JavaCraft?"}{" "}
          <Link to={isRegister ? "/login" : "/register"}>
            {isRegister ? "Sign in" : "Create an account"}
          </Link>
        </div>
        <div className="auth-security">Your password is one-way hashed. Sessions are revocable.</div>
      </div>
    </main>
  );
}
