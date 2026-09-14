import { chmodSync, existsSync, unlinkSync } from 'node:fs';
import { createServer, Server, Socket } from 'node:net';
import { join } from 'node:path';
import { tmpdir } from 'node:os';

export interface BridgeStatus {
  connectedSessions: number;
  pending: boolean;
  message: string;
}

interface Session { provider: 'codex' | 'claude'; id: string; lastSeen: number }
interface Pending { sessionKey: string; expiresAt: number }

export class AgentBridge {
  readonly socketPath = join(tmpdir(), `ballmer-${process.getuid?.() ?? 'user'}.sock`);
  private server?: Server;
  private sessions = new Map<string, Session>();
  private pending?: Pending;
  private recentEvents = new Set<string>();

  constructor(private readonly onSkillInvoked: () => void, private readonly onStatus: () => void) {}

  start(): void {
    if (existsSync(this.socketPath)) unlinkSync(this.socketPath);
    this.server = createServer(socket => this.read(socket));
    this.server.listen(this.socketPath, () => chmodSync(this.socketPath, 0o600));
  }

  stop(): void { this.server?.close(); if (existsSync(this.socketPath)) unlinkSync(this.socketPath); }

  arm(): BridgeStatus {
    this.expire();
    const sessions = [...this.sessions.values()].filter(session => Date.now() - session.lastSeen < 30 * 60_000);
    if (sessions.length !== 1) return this.status(sessions.length ? 'Choose one active task before arming Ballmer.' : 'Wine served. Agent not connected yet.');
    this.pending = { sessionKey: key(sessions[0]), expiresAt: Date.now() + 10 * 60_000 };
    this.onStatus();
    return this.status('Ballmer ready for your next prompt.');
  }

  cancel(): BridgeStatus { this.pending = undefined; this.onStatus(); return this.status('Request cancelled.'); }

  status(message?: string): BridgeStatus {
    this.expire();
    return { connectedSessions: this.sessions.size, pending: Boolean(this.pending), message: message ?? (this.pending ? 'Ballmer ready for your next prompt.' : `${this.sessions.size} agent task${this.sessions.size === 1 ? '' : 's'} seen`) };
  }

  private read(socket: Socket): void {
    socket.setEncoding('utf8');
    let input = '';
    socket.on('data', chunk => { input += chunk; if (input.length > 2048) socket.destroy(); });
    socket.on('end', () => this.handle(input.trim(), socket));
  }

  private handle(line: string, socket: Socket): void {
    const [version, provider, sessionId, eventId, invokedText] = line.split('\t');
    if (version !== '1' || !/^(codex|claude)$/.test(provider) || !safeId(sessionId) || !safeId(eventId) || !/^[01]$/.test(invokedText)) { socket.end('error\n'); return; }
    const session = { provider: provider as Session['provider'], id: sessionId, lastSeen: Date.now() };
    this.sessions.set(key(session), session);
    const invoked = invokedText === '1';
    if (invoked && !this.recentEvents.has(eventId)) { this.recentEvents.add(eventId); this.onSkillInvoked(); }
    this.expire();
    const consumesPending = this.pending?.sessionKey === key(session);
    if (consumesPending) this.pending = undefined;
    this.onStatus();
    socket.end(`${consumesPending ? 'activate' : 'ok'}\n`);
  }

  private expire(): void { if (this.pending && this.pending.expiresAt <= Date.now()) this.pending = undefined; }
}

const key = (session: Session) => `${session.provider}:${session.id}`;
const safeId = (value: string | undefined) => Boolean(value && value.length <= 160 && /^[A-Za-z0-9_.:-]+$/.test(value));
