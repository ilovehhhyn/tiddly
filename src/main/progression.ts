export const POUR_INTERVAL_MS = 15 * 60 * 1000;
export const REFERENCE_X = 0.13;

export interface ProgressState {
  countedMs: number;
  extraWineCount: number;
  waterCount: number;
  processedPourInterval: number;
  encouraged: boolean;
  celebrated: boolean;
}

export function markerX(state: ProgressState): number {
  const sipEquivalent = Math.max(0, state.countedMs / POUR_INTERVAL_MS + state.extraWineCount - state.waterCount);
  return REFERENCE_X * sipEquivalent / 8;
}

export function curveY(x: number): number {
  return Math.log1p(x / REFERENCE_X) / Math.log(2);
}

export function applyCountedTime<T extends ProgressState>(state: T, countedMs: number): T {
  const next = { ...state, countedMs: Math.max(state.countedMs, countedMs) };
  const interval = Math.floor(next.countedMs / POUR_INTERVAL_MS);
  next.processedPourInterval = Math.max(state.processedPourInterval, interval);
  next.encouraged = state.encouraged || next.countedMs >= 30 * 60 * 1000;
  next.celebrated = state.celebrated || markerX(next) >= REFERENCE_X;
  return next;
}

export function giveWine<T extends ProgressState>(state: T): T {
  const next = { ...state, extraWineCount: state.extraWineCount + 1 };
  next.celebrated = state.celebrated || markerX(next) >= REFERENCE_X;
  return next;
}

export function drinkWater<T extends ProgressState>(state: T): T {
  return { ...state, waterCount: state.waterCount + 1 };
}
