import { execFile } from 'node:child_process';
import { app } from 'electron';
import { join } from 'node:path';

const CODEX_BUNDLE_ID = 'com.openai.codex';

function helperPath(): string {
  return app.isPackaged
    ? join(process.resourcesPath, 'tiddly-frontmost')
    : join(app.getAppPath(), 'dist/native/tiddly-frontmost');
}

/** Observe app identity only; no screenshots, titles, keystrokes, or prompt content. */
export function observeCodexForeground(onResult: (eligible: boolean) => void): void {
  execFile(helperPath(), { timeout: 1000 }, (error, stdout) => {
    if (error) { onResult(false); return; }
    onResult(stdout.trim() === CODEX_BUNDLE_ID);
  });
}
