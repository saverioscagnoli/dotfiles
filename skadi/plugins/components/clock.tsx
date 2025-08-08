import { useEffect, useState } from "react";
import { cn } from "../util";
import { Calendar, ClockIcon } from "lucide-react";

const Clock = () => {
  const [time, setTime] = useState<Date>(new Date());

  useEffect(() => {
    let timeoutID: number;

    const updateTime = () => {
      let now = new Date();

      setTime(now);

      // Schedule next update at exactly the next second boundary
      // This is for auto-correcting timeout drift
      let msUntilNextSecond = 1000 - (now.getTime() % 1000);
      timeoutID = window.setTimeout(updateTime, msUntilNextSecond);
    };

    updateTime();

    return () => {
      clearTimeout(timeoutID);
    };
  }, []);

  return (
    <div
      className={cn(
        "absolute top-0 left-1/2 transform -translate-x-1/2",
        "flex items-center gap-4",
        "rounded-lg",
        "bg-black/50 text-white",
        "border-2 border-white/10",
        "px-4 py-1.5"
      )}
    >
      <div className={cn("flex items-center gap-2")}>
        <Calendar size={18} />
        <p>
          {time.toLocaleDateString("en-US", {
            weekday: "long",
            month: "short",
            day: "numeric"
          })}
        </p>
      </div>
      <div className={cn("flex items-center gap-2")}>
        <ClockIcon size={18} />
        <p>
          {time.toLocaleTimeString("en-US", {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false
          })}
        </p>
      </div>
    </div>
  );
};

export { Clock };
