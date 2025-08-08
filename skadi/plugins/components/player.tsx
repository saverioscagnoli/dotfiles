import React, { useState } from "react";
import { cn } from "../util";
import type { Props } from "../types";
import {
  OpCode,
  Payload,
  SpotifyEvent,
  SpotifyEventType,
  TrackInfo
} from "../payloads";
import { Pause, Play, SkipBack, SkipForward } from "lucide-react";
import { Progress } from "./progress";

const SpotifyIcon = () => {
  return (
    <svg
      role="img"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      className="w-5 h-5 fill-green-500"
    >
      <title>Spotify</title>
      <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z" />
    </svg>
  );
};

const Spotify: React.FC<Props> = ({ exec, useListen }) => {
  const [track, setTrack] = useState<TrackInfo | null>(null);
  const [coverUrl, setCoverUrl] = useState<string | null>(null);
  const [playing, setPlaying] = useState<boolean>(false);

  useListen<Payload<SpotifyEvent>>(
    "/home/svscagn/.config/skadi/scripts/backend",
    p => {
      if (p.op !== OpCode.Spotify) return;

      switch (p.data.type) {
        case SpotifyEventType.Playing:
          if (!coverUrl || p.data.trackInfo?.artworkUrl !== coverUrl) {
            setCoverUrl(p.data.trackInfo?.artworkUrl || null);
          }

          if (!playing) {
            setPlaying(true);
          }

          setTrack(p.data.trackInfo);
          break;

        case SpotifyEventType.Paused:
        case SpotifyEventType.Stopped:
          if (playing) {
            setPlaying(false);
          }
          break;

        case SpotifyEventType.Request:
          setTrack(p.data.trackInfo);
          break;
      }
    }
  );

  return (
    track && (
      <div
        className={cn(
          "flex items-center gap-4",
          "rounded-lg",
          "bg-black/50 text-white",
          "border-2 border-white/10",
          "px-2 py-1.5"
        )}
      >
        {coverUrl ? (
          <img src={coverUrl} alt="Cover" className="w-6 h-6 rounded" />
        ) : (
          <SpotifyIcon />
        )}
        <p>
          {track.artist} - {track.title}
        </p>
        <button className="cursor-pointer">
          <SkipBack
          size={20}
            onClick={() =>
              exec({
                script: "playerctl",
                args: ["--player=spotify", "previous"]
              })
            }
          />
        </button>
        <button className="cursor-pointer">
          {playing ? (
            <Pause
              size={20}
              onClick={() =>
                exec({
                  script: "playerctl",
                  args: ["--player=spotify", "pause"]
                })
              }
            />
          ) : (
            <Play
              size={20}
              onClick={() =>
                exec({
                  script: "playerctl",
                  args: ["--player=spotify", "play"]
                })
              }
            />
          )}
        </button>
        <button className="cursor-pointer">
          <SkipForward
            size={20}
            onClick={() =>
              exec({
                script: "playerctl",
                args: ["--player=spotify", "next"]
              })
            }
          />
        </button>
        <Progress
          className={cn("bg-white/25")}
          value={track.position}
          max={track.duration ?? undefined}
        />
      </div>
    )
  );
};

export { Spotify };
