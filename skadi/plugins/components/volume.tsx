import React, { useEffect, useState, useCallback, useRef } from "react";
import { cn } from "../util";
import { Section } from "./section";
import { Volume1Icon, Volume2, Volume as VolumeIcon } from "lucide-react";
import { Props } from "../types";
import { Slider } from "./slider";
import { OpCode, Payload, VolumeEvent } from "../payloads";

const VOLUME_2_THRESHOLD = 70;
const VOLUME_1_THRESHOLD = 30;

const Volume: React.FC<Props> = ({ exec, useListen }) => {
  const [volume, setVolume] = useState<number>(0);
  const lastVolumeChangeRef = useRef<number>(0);
  const volumeTimeoutRef = useRef<any>(null);

  // Simple throttle that only executes the last call after a delay
  const throttledVolumeChange = useCallback(
    (value: number) => {
      // Clear any pending timeout
      if (volumeTimeoutRef.current) {
        clearTimeout(volumeTimeoutRef.current);
      }

      // Set a new timeout
      volumeTimeoutRef.current = setTimeout(() => {
        const now = Date.now();
        // Only execute if enough time has passed since last execution
        if (now - lastVolumeChangeRef.current >= 200) {
          console.log(`Executing volume change: ${value}%`);
          lastVolumeChangeRef.current = now;

          // Use the most basic exec call possible
          exec({
            script: "pactl",
            args: ["set-sink-volume", "@DEFAULT_SINK@", `${value}%`],
            resolves: false
          });
        }
      }, 200);
    },
    [exec]
  );

  useListen<Payload<VolumeEvent>>(
    "/home/svscagn/.config/skadi/scripts/backend",
    p => {
      if (p.op !== OpCode.Volume) return;
      setVolume(p.data.volume);
    }
  );

  useEffect(() => {
    const fetchVolume = async () => {
      try {
        let result = await exec<string>({
          script: "sh",
          args: [
            "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/[%,]//g'"
          ]
        });

        if (result) {
          setVolume(Math.min(parseInt(result.trim(), 10), 100));
        }
      } catch (error) {
        console.error("Failed to fetch volume:", error);
      }
    };

    fetchVolume();
  }, [exec]);

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (volumeTimeoutRef.current) {
        clearTimeout(volumeTimeoutRef.current);
      }
    };
  }, []);

  return (
    <Section className={cn("flex items-center gap-4", "px-2 py-1.5")}>
      {volume >= VOLUME_2_THRESHOLD ? (
        <Volume2 size={20} className="text-white" />
      ) : volume >= VOLUME_1_THRESHOLD ? (
        <Volume1Icon size={20} className="text-white" />
      ) : (
        <VolumeIcon size={20} className="text-white opacity-50" />
      )}
      <Slider
        trackClassName={cn("bg-white/25")}
        thumbClassName={cn("bg-white")}
        value={[volume]}
        max={100}
        step={5}
        onValueChange={([value]) => {
          setVolume(value);
          throttledVolumeChange(value);
        }}
      />
    </Section>
  );
};

export { Volume };
