import React from "react";
import * as RxSlider from "@radix-ui/react-slider";
import { cn } from "../util";
import { cva, type VariantProps } from "class-variance-authority";

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

const sliderRangeVariants = cva(["h-full", "absolute", "rounded-full"], {
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

type SliderProps = RxSlider.SliderProps &
  VariantProps<typeof sliderRangeVariants> & {
    trackClassName?: string;
    thumbClassName?: string;
  };

export type { SliderProps };

const Slider: React.FC<SliderProps> = ({
  colorScheme = "plum",
  trackClassName,
  thumbClassName,
  className,
  ...props
}) => {
  return (
    <RxSlider.Root
      className={cn(
        "w-[12.5rem] h-1.5",
        "relative flex items-center",
        "select-none touch-none",
        className
      )}
      {...props}
    >
      <RxSlider.Track
        className={cn(
          "h-full",
          "relative flex-1",
          "rounded-full",
          "bg-[var(--gray-5)]",
          trackClassName
        )}
      >
        <RxSlider.Range
          className={sliderRangeVariants({ className, colorScheme })}
        />
      </RxSlider.Track>
      <RxSlider.Thumb
        className={cn(
          "w-4 h-4",
          "rounded-full",
          "block",
          "shadow",
          "outline-none",
          "bg-[var(--slate-12)]",
          "dark:bg-[var(--slate-1)]",
    
          thumbClassName
        )}
      />
    </RxSlider.Root>
  );
};

Slider.displayName = "Slider";

export { Slider };
