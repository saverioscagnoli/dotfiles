type ExecMessage = {
    success: boolean;
    stdout: string,
    stderr: string,
    exitCode: number
}

type ExecFunction = (command: string, args?: string[]) => Promise<ExecMessage>;
type ListenFunction = (script: string, callback: (data: string) => void) => void;