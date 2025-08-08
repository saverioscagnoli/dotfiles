import type { ClassValue } from "clsx";

import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export const cn = (...inputs: ClassValue[]) => {
  return twMerge(clsx(inputs));
};

export const bytesTo = (b: number, unit: "KB" | "MB" | "GB" | "TB"): number => {
  switch (unit) {
    case "KB":
      return b / 1024;
    case "MB":
      return b / (1024 * 1024);
    case "GB":
      return b / (1024 * 1024 * 1024);
    case "TB":
      return b / (1024 * 1024 * 1024 * 1024);
  }
};
