type MetricsGraphProps = {
  metric: string;
  value: number;
};

const MetricsGraph: React.FC<MetricsGraphProps> = ({ metric, value }) => {
  const getBar = (val: number) => {
    const segments = Math.round((val / 100) * 8);
    return "▁▂▃▄▅▆▇█".substring(0, Math.max(1, segments));
  };

  const getColor = (val: number) => {
    if (val > 75) return "text-red-500";
    if (val > 50) return "text-yellow-600";
    return "text-green-500";
  };

  return (
    <div className="flex items-center gap-1 whitespace-nowrap">
      <span className="text-muted-foreground">{metric}</span>
      <span className={`font-bold w-7 text-right ${getColor(value)}`}>
        {value.toString().padStart(2, "0")}%
      </span>
      <span className={`text-[9px] w-3 ${getColor(value)}`}>
        {getBar(value)}
      </span>
    </div>
  );
};

export { MetricsGraph };
