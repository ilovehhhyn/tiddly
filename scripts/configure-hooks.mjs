import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const hook = join(root, 'hooks', 'ballmer-hook.mjs');
const command = provider => `${JSON.stringify(process.execPath)} ${JSON.stringify(hook)} ${provider}`;

const files = [
  [join(root, '.codex', 'hooks.json'), {
    description: 'Tiddly: connect the Ballmer skill command to the local desktop pet.',
    hooks: { UserPromptSubmit: [{ hooks: [{
      type: 'command', command: command('codex'), timeout: 1,
      additionalContextLimit: 200, statusMessage: 'Telling Tiddly'
    }] }] }
  }],
  [join(root, '.claude', 'settings.local.json'), {
    hooks: { UserPromptSubmit: [{ hooks: [{
      type: 'command', command: command('claude'), timeout: 1
    }] }] }
  }]
];

for (const [path, value] of files) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 });
}

console.log('Configured repository hooks for this checkout.');
