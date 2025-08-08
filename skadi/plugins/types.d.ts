type Props = {
  exec: <T>(params: {
    script: string;
    polls?: boolean;
    args?: string[];
    resolves?: boolean;
  }) => Promise<T>;
  useListen: <T>(script: string, callback: (data: T) => void) => void;
};

export type { Props };
