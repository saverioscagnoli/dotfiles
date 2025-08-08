import { useEffect, useState } from "react";
import { Props } from "../types";
import { bytesTo, cn } from "../util";
import { ArrowDown, ArrowUp, Cpu, MemoryStick, Server } from "lucide-react";
import { Section } from "./section";
import { OpCode, Payload, SysinfoPayload } from "../payloads";

import "@radix-ui/colors/plum.css";
import "@radix-ui/colors/plum-dark.css";
import "@radix-ui/colors/cyan.css";
import "@radix-ui/colors/cyan-dark.css";

type NetworkDataPoint = {
  timestamp: number;
  up: number;
  down: number;
};

const formatNetworkBytes = (bytes: number): string => {
  if (bytes < 1024) return `${bytes.toFixed(0)} B/s`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB/s`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB/s`;
};

const MiniChart: React.FC<{ data: NetworkDataPoint[] }> = ({ data }) => {
  if (data.length < 2) return null;

  const maxValue = Math.max(...data.flatMap(d => [d.up, d.down]), 1); // Prevent division by zero
  const width = 80;
  const height = 24;
  const padding = 2;

  const points = data.map((point, index) => {
    const x = padding + (index / (data.length - 1)) * (width - 2 * padding);
    const yUp =
      height - padding - (point.up / maxValue) * (height - 2 * padding);
    const yDown =
      height - padding - (point.down / maxValue) * (height - 2 * padding);
    return { x, yUp, yDown };
  });

  // Create smooth curves using quadratic bezier curves
  const createSmoothPath = (points: { x: number; y: number }[]) => {
    if (points.length < 2) return "";

    let path = `M ${points[0].x} ${points[0].y}`;

    for (let i = 1; i < points.length; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const cpx = (prev.x + curr.x) / 2;
      path += ` Q ${cpx} ${prev.y} ${curr.x} ${curr.y}`;
    }

    return path;
  };

  const upPath = createSmoothPath(points.map(p => ({ x: p.x, y: p.yUp })));
  const downPath = createSmoothPath(points.map(p => ({ x: p.x, y: p.yDown })));

  // Create filled area paths
  const upAreaPath =
    upPath +
    ` L ${points[points.length - 1].x} ${height - padding} L ${padding} ${
      height - padding
    } Z`;
  const downAreaPath =
    downPath +
    ` L ${points[points.length - 1].x} ${height - padding} L ${padding} ${
      height - padding
    } Z`;

  return (
    <div className="relative">
      <svg
        width={width}
        height={height}
        className="overflow-hidden rounded-sm"
        style={{ background: "rgba(0,0,0,0.05)" }}
      >
        <defs>
          <linearGradient id="upGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="var(--cyan-9)" stopOpacity="0.3" />
            <stop offset="100%" stopColor="var(--cyan-9)" stopOpacity="0.05" />
          </linearGradient>
          <linearGradient id="downGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="var(--plum-9)" stopOpacity="0.3" />
            <stop offset="100%" stopColor="var(--plum-9)" stopOpacity="0.05" />
          </linearGradient>
        </defs>

        {/* Grid lines */}
        <defs>
          <pattern id="grid" width="8" height="6" patternUnits="userSpaceOnUse">
            <path
              d="M 8 0 L 0 0 0 6"
              fill="none"
              stroke="rgba(0,0,0,0.1)"
              strokeWidth="0.5"
            />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" />

        {/* Filled areas */}
        <path d={upAreaPath} fill="url(#upGradient)" />
        <path d={downAreaPath} fill="url(#downGradient)" />

        {/* Line strokes */}
        <path
          d={upPath}
          stroke="var(--cyan-9)"
          strokeWidth="1.5"
          fill="none"
          opacity="0.9"
        />
        <path
          d={downPath}
          stroke="var(--plum-9)"
          strokeWidth="1.5"
          fill="none"
          opacity="0.9"
        />

        {/* Current value indicators */}
        {points.length > 0 && (
          <>
            <circle
              cx={points[points.length - 1].x}
              cy={points[points.length - 1].yUp}
              r="1.5"
              fill="var(--cyan-9)"
              opacity="0.8"
            />
            <circle
              cx={points[points.length - 1].x}
              cy={points[points.length - 1].yDown}
              r="1.5"
              fill="var(--plum-9)"
              opacity="0.8"
            />
          </>
        )}
      </svg>
    </div>
  );
};

const SysInfo: React.FC<Props> = ({ exec, useListen }) => {
  const [metrics, setMetrics] = useState<SysinfoPayload | null>(null);
  const [netHistory, setNetHistory] = useState<NetworkDataPoint[]>([
    { timestamp: Date.now(), up: 0, down: 0 }
  ]);

  useListen<Payload<SysinfoPayload>>(
    "/home/svscagn/.config/skadi/scripts/backend",
    p => {
      if (p.op !== OpCode.Sysinfo) return;
      setMetrics(p.data);
      setNetHistory(prev => {
        let newPoint: NetworkDataPoint = {
          timestamp: Date.now(),
          up: p.data.networkTx,
          down: p.data.networkRx
        };
        let updatedHistory = [...prev, newPoint].slice(-30);

        return updatedHistory;
      });
    }
  );

  return (
    metrics && (
      <Section
        className={cn(
          "flex items-center gap-4",
          "px-2 py-1.5",
          "whitespace-nowrap overflow-hidden"
        )}
      >
        <span className={cn("flex items-center gap-2 flex-shrink-0")}>
          <Cpu size={18} />
          <p className="text-sm w-10">{metrics.cpuUsage.toFixed(0)}%</p>
        </span>
        <span className={cn("flex items-center gap-2 flex-shrink-0")}>
          <MemoryStick size={18} />
          <p className="text-sm whitespace-nowrap">
            {bytesTo(metrics.memoryUsed, "GB").toFixed(1)} /{" "}
            {bytesTo(metrics.memoryTotal, "GB").toFixed(1)} GB (
            {(
              ((metrics.memoryTotal - metrics.memoryUsed) /
                metrics.memoryTotal) *
              100
            ).toFixed(1)}
            %)
          </p>
        </span>
        <span className={cn("flex items-center gap-2 flex-shrink-0")}>
          <ArrowUp size={18} color="var(--cyan-9)" />
          <p className="text-sm w-16">
            {formatNetworkBytes(metrics.networkTx)}
          </p>
        </span>
        <span className={cn("flex items-center gap-2 flex-shrink-0")}>
          <ArrowDown size={18} color="var(--plum-9)" />
          <p className="text-sm w-16">
            {formatNetworkBytes(metrics.networkRx)}
          </p>
        </span>
        <div className={cn("flex items-center gap-1.5 min-w-0")}>
          <MiniChart data={netHistory} />
        </div>
      </Section>
    )
  );
};

export { SysInfo };
