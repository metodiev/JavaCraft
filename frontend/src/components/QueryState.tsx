import { AlertCircle, LoaderCircle } from "lucide-react";
import type { ReactNode } from "react";

export function QueryState({
  isLoading,
  error,
  children,
}: {
  isLoading: boolean;
  error: Error | null;
  children: ReactNode;
}) {
  if (isLoading) {
    return (
      <div className="state-panel" role="status">
        <LoaderCircle className="spin" size={20} />
        <span>Connecting to JavaCraft…</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="state-panel state-error" role="alert">
        <AlertCircle size={20} />
        <div>
          <strong>We couldn’t load this workspace.</strong>
          <p>{error.message}. Make sure the API is running and try again.</p>
        </div>
      </div>
    );
  }

  return children;
}
