import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "./AuthContext";

export function ProtectedRoute() {
  const { learner, loading, error } = useAuth();
  const location = useLocation();

  if (loading) return <div className="auth-loading">Restoring your JavaCraft session…</div>;
  if (error) {
    return (
      <div className="auth-loading auth-load-error" role="alert">
        <strong>Couldn’t connect to JavaCraft.</strong>
        <span>{error.message}</span>
        <button onClick={() => window.location.reload()}>Try again</button>
      </div>
    );
  }
  if (!learner) return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  return <Outlet />;
}
