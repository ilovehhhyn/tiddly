import { connect } from 'node:net';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const provider = process.argv[2];
let body = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { body += chunk; if (body.length > 1024 * 1024) process.exit(0); });
process.stdin.on('end', () => {
  const input = JSON.parse(body);
  const prompt = typeof input.prompt === 'string' ? input.prompt : '';
  const sessionId = String(input.session_id ?? 'unknown').replace(/[^A-Za-z0-9_.:-]/g, '').slice(0, 160);
  const eventId = String(input.turn_id ?? `${Date.now()}`).replace(/[^A-Za-z0-9_.:-]/g, '').slice(0, 160);
  const invoked = provider === 'codex' ? /^\s*\$ballmer(?:\s|$)/i.test(prompt) : /^\s*\/ballmer(?:\s|$)/i.test(prompt);
  const socket = connect(join(tmpdir(), `ballmer-${process.getuid?.() ?? 'user'}.sock`));
  socket.setTimeout(250);
  socket.on('connect', () => socket.end(`1\t${provider}\t${sessionId}\t${eventId}\t${invoked ? 1 : 0}`));
  socket.on('data', chunk => {
    if (String(chunk).trim() !== 'activate') return;
    const instruction = provider === 'codex'
      ? 'Use the installed $ballmer skill for this user task. Load its complete SKILL.md and follow it without replacing the user request.'
      : 'Use the installed /ballmer skill for this user task. Load its complete SKILL.md and follow it without replacing the user request.';
    process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'UserPromptSubmit', additionalContext: instruction } }));
  });
  socket.on('timeout', () => socket.destroy());
  socket.on('error', () => process.exit(0));
});
