enum OpCode {
  Error = 0,
  Sysinfo = 1,
  WindowChanged = 2,
  Workspace = 3,
  Spotify = 4,
  Volume = 5
}

type Payload<T> = {
  op: OpCode;
  data: T;
};

type SysinfoPayload = {
  cpuUsage: number;
  memoryUsed: number;
  memoryTotal: number;
  memoryFree: number;
  swapUsed: number;
  swapTotal: number;
  networkRx: number;
  networkTx: number;
  diskRead: number;
  diskWrite: number;
  diskUsage: number;
  diskTotal: number;
  diskFree: number;
};

enum WorkspaceEventType {
  Moved = "Moved",
  Created = "Created",
  Destroyed = "Destroyed"
}

type Workspace = {
  id: number;
  type: WorkspaceEventType;
};

type TrackInfo = {
  length: number;
  title: string | null;
  artist: string | null;
  album: string | null;
  status: string;
  position: number | null;
  duration: number | null;
  volume: string | null;
  artworkUrl: string | null;
};

enum SpotifyEventType {
  Request = "Request",
  Playing = "Playing",
  Paused = "Paused",
  Stopped = "Stopped"
}

type SpotifyEvent = {
  type: SpotifyEventType;
  trackInfo: TrackInfo | null;
};

type VolumeEvent = {
  volume: number;
};

export {
  OpCode,
  Payload,
  SysinfoPayload,
  WorkspaceEventType,
  Workspace,
  TrackInfo,
  SpotifyEvent,
  SpotifyEventType,
  VolumeEvent
};
