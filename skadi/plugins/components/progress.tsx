import React from "react";
import * as RxProgress from "@radix-ui/react-progress";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../util";

import "@radix-ui/colors/plum.css";
import "@radix-ui/colors/plum-dark.css";

import "@radix-ui/colors/teal.css";
import "@radix-ui/colors/teal-dark.css";

import "@radix-ui/colors/grass.css";
import "@radix-ui/colors/grass-dark.css";

import "@radix-ui/colors/red.css";
import "@radix-ui/colors/red-dark.css";

import "@radix-ui/colors/amber.css";
import "@radix-ui/colors/amber-dark.css";

import "@radix-ui/colors/blue.css";
import "@radix-ui/colors/blue-dark.css";

import "@radix-ui/colors/gray.css";
import "@radix-ui/colors/gray-dark.css";

import "@radix-ui/colors/slate.css";
import "@radix-ui/colors/slate-dark.css";

//import "./progress.css";

const progressIndicatorVariants = cva(["w-full h-full", "rounded-full"], {
  variants: {
    colorScheme: {
      plum: "bg-[var(--plum-9)]",
      red: "bg-[var(--red-9)]",
      blue: "bg-[var(--blue-9)]",
      teal: "bg-[var(--teal-9)]",
      cyan: "bg-[var(--cyan-9)]",
      green: "bg-[var(--green-9)]",
      amber: "bg-[var(--amber-9)]",
      orange: "bg-[var(--orange-9)]",
      gray: "bg-[var(--slate-12)]"
    }
  },
  defaultVariants: {
    colorScheme: "plum"
  }
});

type ProgressProps = RxProgress.ProgressProps &
  VariantProps<typeof progressIndicatorVariants> & {
    indefinite?: boolean;
  };

export type { ProgressProps };

const Progress: React.FC<ProgressProps> = ({
  colorScheme = "plum",
  value,
  max = 100,
  indefinite = false,
  className,
  ...props
}) => {
  value = value ?? 0;

  return (
    <RxProgress.Root
      className={cn(
        "w-[12.5rem] h-1.5",
        "relative",
        "bg-[var(--gray-5)]",
        "overflow-hidden",
        "rounded-full",
        "progress",
        className
      )}
      value={value}
      max={max}
      {...props}
    >
      <RxProgress.Indicator
        className={progressIndicatorVariants({
          className: cn(indefinite && "indefinite", "progress-indicator"),
          colorScheme
        })}
        style={{
          transform: `translateX(-${100 - (value / max) * 100}%`
        }}
      />
    </RxProgress.Root>
  );
};

Progress.displayName = "Progress";

export { Progress };
