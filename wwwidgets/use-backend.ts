import { createContext, useContext } from "react";

type BackendContextType = {
  exec: ExecFunction;
  useListen: ListenFunction;
};

const BackendContext = createContext<BackendContextType | null>(null);

function useBackend() {
  const ctx = useContext(BackendContext);

  if (!ctx) {
    throw new Error("useBackend must be used within a BackendProvider");
  }

  return ctx;
}

export { BackendContext, useBackend };
