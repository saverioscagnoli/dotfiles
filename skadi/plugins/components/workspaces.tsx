import React, { useEffect, useState } from "react";
import { cn } from "../util";
import { Props } from "../types";
import { OpCode, Payload, Workspace, WorkspaceEventType } from "../payloads";

const Workspaces: React.FC<Props> = ({ exec, useListen }) => {
  const [active, setActive] = useState<number>(1);
  const [workspaces, setWorkspaces] = useState<Set<number>>(new Set([1]));

  // Get initial workspace state on mount
  useEffect(() => {
    const getInitialWorkspaces = async () => {
      let result = await exec<string>({
        script: "hyprctl",
        args: ["workspaces", "-j"]
      });

      if (!result) {
        console.error("Failed to get initial workspace state");
        return;
      }

      let workspaceData = JSON.parse(result);
      let workspaceIds = workspaceData.map((ws: any) => ws.id);

      setWorkspaces(new Set(workspaceIds));

      // Get current active workspace
      let activeResult = await exec<string>({
        script: "hyprctl",
        args: ["activeworkspace", "-j"]
      });

      if (!activeResult) {
        console.error("Failed to get active workspace");
        return;
      }

      let activeData = JSON.parse(activeResult);

      setActive(activeData.id);
    };

    getInitialWorkspaces();
  }, [exec]);

  useListen<Payload<Workspace>>(
    "/home/svscagn/.config/skadi/scripts/backend",
    p => {
      if (p.op !== OpCode.Workspace) return;

      switch (p.data.type) {
        case WorkspaceEventType.Moved:
          setActive(p.data.id);
          break;
        case WorkspaceEventType.Created:
          setWorkspaces(prev => new Set([...prev, p.data.id]));
          break;
        case WorkspaceEventType.Destroyed:
          setWorkspaces(prev => {
            const newSet = new Set(prev);
            newSet.delete(p.data.id);
            return newSet;
          });
          // If the destroyed workspace was active, switch to the first available workspace
          if (p.data.id === active) {
            setWorkspaces(currentWorkspaces => {
              const remaining = Array.from(currentWorkspaces).filter(
                id => id !== p.data.id
              );
              if (remaining.length > 0) {
                setActive(Math.min(...remaining));
              }
              return new Set(remaining);
            });
          }
          break;
      }
    }
  );

  return (
    <div
      className={cn(
        "flex items-center gap-2",
        "rounded-lg",
        "bg-black/50 text-white",
        "border-2 border-white/10",
        "px-2 py-1.5"
      )}
    >
      <div className="flex gap-1">
        {Array.from(workspaces)
          .sort((a, b) => a - b)
          .map(workspaceNum => {
            const isActive = workspaceNum === active;

            return (
              <div
                key={workspaceNum}
                className={cn(
                  "px-2 py-0.5 rounded text-sm font-medium cursor-pointer",
                  "transition-all duration-300 ease-out",
                  isActive
                    ? "bg-white/20 text-white scale-105"
                    : "text-white/50 hover:text-white/70"
                )}
                onClick={() =>
                  exec({
                    script: "hyprctl",
                    args: ["dispatch", "workspace", workspaceNum.toString()]
                  })
                }
              >
                {workspaceNum}
              </div>
            );
          })}
      </div>
    </div>
  );
};

export { Workspaces };
