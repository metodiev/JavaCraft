import { useQueryClient } from "@tanstack/react-query";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { api, type Learner } from "../lib/api";

interface AuthContextValue {
  learner: Learner | null;
  loading: boolean;
  error: Error | null;
  login: (email: string, password: string) => Promise<void>;
  register: (displayName: string, email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [learner, setLearner] = useState<Learner | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const queryClient = useQueryClient();

  useEffect(() => {
    const controller = new AbortController();
    api.auth
      .me(controller.signal)
      .then(setLearner)
      .catch((cause: unknown) => {
        if (!controller.signal.aborted) {
          setError(cause instanceof Error ? cause : new Error("Unable to restore your session"));
        }
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });
    return () => controller.abort();
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    setError(null);
    setLearner(await api.auth.login(email, password));
  }, []);

  const register = useCallback(
    async (displayName: string, email: string, password: string) => {
      setError(null);
      setLearner(await api.auth.register(displayName, email, password));
    },
    [],
  );

  const logout = useCallback(async () => {
    await api.auth.logout();
    setLearner(null);
    queryClient.clear();
  }, [queryClient]);

  const value = useMemo(
    () => ({ learner, loading, error, login, register, logout }),
    [learner, loading, error, login, register, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}
