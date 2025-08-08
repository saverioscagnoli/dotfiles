import React, { ComponentProps } from "react";
import { cn } from "../util";

const Section: React.FC<ComponentProps<"div">> = ({ className, ...props }) => {
  return (
    <div
      className={cn(
        "h-screen",
        "rounded-lg",
        "bg-black/50 text-white",
        "border-2 border-white/10",
        className
      )}
      {...props}
    />
  );
};

export { Section };
