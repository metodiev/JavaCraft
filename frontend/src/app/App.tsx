import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AppShell } from "../components/AppShell";
import { ChallengePage } from "../features/challenges/ChallengePage";
import { DashboardPage } from "../features/dashboard/DashboardPage";
import { LearningPathPage } from "../features/learning/LearningPathPage";
import { TutorialPage } from "../features/tutorials/TutorialPage";
import { TutorialsPage } from "../features/tutorials/TutorialsPage";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route element={<AppShell />}>
            <Route index element={<DashboardPage />} />
            <Route path="learning-path" element={<LearningPathPage />} />
            <Route path="tutorials" element={<TutorialsPage />} />
            <Route path="tutorials/:slug" element={<TutorialPage />} />
            <Route path="challenges/:slug" element={<ChallengePage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
