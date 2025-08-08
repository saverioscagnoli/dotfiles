import React, { use, useEffect } from "react";
import { Props } from "./types";
import { cn } from "./util";
import { Clock } from "./components/clock";
import { SysInfo } from "./components/sysinfo";
import { Workspaces } from "./components/workspaces";
import { Spotify } from "./components/player";
import { Power } from "lucide-react";
import { Section } from "./components/section";
import { Volume } from "./components/volume";

const Topbar: React.FC<Props> = ({ exec, useListen }) => {
  useEffect(() => {
    exec({
      script: "/home/svscagn/.config/skadi/scripts/backend",
      args: ["--sysinfo-poll-interval", "2"],
      polls: true
    });
  }, []);

  return (
    <div
      className={cn(
        "w-full h-full",
        "flex items-center justify-between",
        "bg-transparent",
        "select-none",
        "overflow-y-hidden",
        "text-white"
      )}
    >
      <div className={cn("flex items-center gap-4", "py-2")}>
        <Workspaces exec={exec} useListen={useListen} />
        <Spotify exec={exec} useListen={useListen} />
        <Volume exec={exec} useListen={useListen} />
      </div>
      <Clock />
      <span className={cn("flex items-center gap-4")}>
        <SysInfo exec={exec} useListen={useListen} />
        <Section className={cn("flex items-center", "px-2 py-1.5")}>
          <button>
            <Power size={20} onClick={() => exec({ script: "wlogout" })} />
          </button>
        </Section>
      </span>
    </div>
  );
};

export default Topbar;
