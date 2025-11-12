import { useState } from "react";
import { useBackend } from "../../use-backend";

const WorkspaceIndicator = () => {
  const [active, setActive] = useState("");
  const [workspaces, setWorkspaces] = useState<string[]>([]);

  const { exec, useListen } = useBackend();

  useListen("wwwatch --workspaces", (p) => {
    let data = JSON.parse(p);

    if (data.op !== "workspaces") return;

    console.log(data);
    setActive(data.current);
    setWorkspaces(data.total);
  });

  return (
    <div className="flex items-center gap-1 px-1 py-0.5 bg-[#222222] rounded-sm whitespace-nowrap">
      {workspaces.map((ws, idx) => (
        <button
          key={ws}
          onClick={() => {
            setActive(ws);
            exec("swaymsg", ["workspace", (idx + 1).toString()]);
          }}
          className={`w-5 h-5 flex items-center justify-center rounded-xs text-[11px] font-bold transition-colors flex-shrink-0 ${
            ws === active ? "bg-red-500 text-black" : "bg-black text-gray-300"
          }`}
          title={`Workspace ${ws}`}
        >
          {ws}
        </button>
      ))}
    </div>
  );
};

export { WorkspaceIndicator };
