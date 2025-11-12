import { use, useEffect } from "react";
import { useBackend } from "../use-backend";
import { WorkspaceIndicator } from "./components/workspaces";
import { Clock } from "./components/clock";
import { Info } from "./components/info";

import "./topbar.css";

const Topbar = () => {
  const { exec, useListen } = useBackend();

  useEffect(() => {
    exec("echo", ["Hello!"]).then((r) => {
      console.log(r.stdout);
    });
  }, []);

  return (
    <div className="w-screen h-screen select-none flex items-center justify-between geist-mono px-2 pr-8">
      <WorkspaceIndicator />
      <Clock />
      <Info />
    </div>
  );
};

export default Topbar;
