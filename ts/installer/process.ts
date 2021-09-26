const uv_spawn: (
  cmd: string,
  options: any,
  on_exit: (code: number, singal: number) => void
) => LuaMultiReturn<[handle: number, pid: number]> = vim.loop.spawn;

export async function spawn(
  cmd: string,
  cwd: string,
  on_pipe: (type: string, mes: string) => void
) {
  return new Promise((resolve, reject) => {
    const stdin = vim.loop.new_pipe();
    const stdout = vim.loop.new_pipe();
    const stderr = vim.loop.new_pipe();

    const [handle, pid] = uv_spawn(
      cmd,
      {
        stdio: [stdin, stdout, stderr],
        cwd,
      },
      (code, signal) => {
        resolve([code, signal]);
      }
    );

    vim.loop.read_start(stdout, (err: any, data: string) => {
      on_pipe("stdout", data);
    });

    vim.loop.read_start(stderr, (err: any, data: string) => {
      on_pipe("stderr", data);
    });
  });
}
