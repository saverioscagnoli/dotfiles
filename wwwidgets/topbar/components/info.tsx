import { MetricsGraph } from "./metrics-graph";
import { useEffect, useState } from "react";

const Info = () => {
  const [metrics, setMetrics] = useState({
    cpu: 45,
    memory: 62,
    network: { up: 1.2, down: 3.4 },
  });
  useEffect(() => {
    const interval = setInterval(() => {
      setMetrics({
        cpu: Math.floor(Math.random() * 100),
        memory: Math.floor(Math.random() * 100),
        network: {
          up: Math.random() * 5,
          down: Math.random() * 10,
        },
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex text-gray-300 text-sm">
      <div className="flex-shrink-0">
        <MetricsGraph metric="MEM" value={metrics.memory} />
      </div>
      <div className="text-gray-300 flex-shrink-0">│</div>
    </div>
  );
};

export { Info };
