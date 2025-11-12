import { useEffect, useState } from "react";
import { format } from "date-fns";

const formatDate = (d: Date) => format(d, "EEE MMM d HH:mm"); 

const Clock = () => {
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    const update = () => setNow(new Date());

    const msUntilNextMinute =
      (60 - now.getSeconds()) * 1000 - now.getMilliseconds();

    const timeoutId = window.setTimeout(() => {
      update();
      const intervalId = window.setInterval(update, 60_000);
      return () => clearInterval(intervalId);
    }, msUntilNextMinute);

    return () => clearTimeout(timeoutId);
  }, [now]);

  return <div className="text-sm text-gray-200">{formatDate(now)}</div>;
};

export { Clock };
