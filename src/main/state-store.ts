import { app, screen } from 'electron';
import { existsSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import type { ProgressState } from './progression';

export interface PetState extends ProgressState {
  version: 1;
  sessionId: string;
  paused: boolean;
  characterId: 'hedgehog' | 'owl';
  position?: { x: number; y: number };
}

export const initialState = (): PetState => ({
  version: 1, sessionId: crypto.randomUUID(), paused: false,
  characterId: 'hedgehog', countedMs: 0, extraWineCount: 0, waterCount: 0,
  processedPourInterval: 0, encouraged: false, celebrated: false
});

export class StateStore {
  private readonly path = join(app.getPath('userData'), 'pet-state.json');

  load(): PetState {
    if (!existsSync(this.path)) return initialState();
    const parsed: unknown = JSON.parse(readFileSync(this.path, 'utf8'));
    if (!parsed || typeof parsed !== 'object') throw new Error(`Invalid Tiddly state at ${this.path}`);
    const migrated: unknown = { waterCount: 0, ...parsed };
    if (!isPetState(migrated)) throw new Error(`Invalid Tiddly state at ${this.path}`);
    return migrated;
  }

  save(state: PetState): void {
    const draft = `${this.path}.new`;
    writeFileSync(draft, JSON.stringify(state, null, 2), { mode: 0o600 });
    renameSync(draft, this.path);
  }
}

function isPetState(value: unknown): value is PetState {
  if (!value || typeof value !== 'object') return false;
  const state = value as Partial<PetState>;
  return state.version === 1 && typeof state.countedMs === 'number' &&
    typeof state.extraWineCount === 'number' &&
    typeof state.waterCount === 'number' &&
    (state.characterId === 'hedgehog' || state.characterId === 'owl');
}

export function defaultPosition(width: number, height: number): { x: number; y: number } {
  const work = screen.getPrimaryDisplay().workArea;
  return { x: work.x + work.width - width - 24, y: work.y + work.height - height - 24 };
}
