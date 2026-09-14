import { describe, expect, it } from 'vitest';
import { applyCountedTime, curveY, drinkWater, giveWine, markerX, POUR_INTERVAL_MS } from '../src/main/progression';

const start = () => ({ countedMs: 0, extraWineCount: 0, waterCount: 0, processedPourInterval: 0, encouraged: false, celebrated: false });

describe('fictional progression', () => {
  it('reaches 0.13 at two automatic hours', () => expect(markerX(applyCountedTime(start(), 8 * POUR_INTERVAL_MS))).toBeCloseTo(0.13));
  it('continues rising after two hours', () => expect(markerX(applyCountedTime(start(), 10 * POUR_INTERVAL_MS))).toBeGreaterThan(0.13));
  it('advances wine without changing counted time', () => { const next = giveWine(start()); expect(next.countedMs).toBe(0); expect(markerX(next)).toBeCloseTo(0.01625); });
  it('moves backward by one sip after water', () => {
    const withWine = giveWine(giveWine(start()));
    expect(markerX(drinkWater(withWine))).toBeCloseTo(markerX(giveWine(start())));
  });
  it('does not move below zero after water', () => expect(markerX(drinkWater(start()))).toBe(0));
  it('passes the curve through the reference', () => expect(curveY(0.13)).toBeCloseTo(1));
  it('processes delayed interval crossings once', () => expect(applyCountedTime(start(), 31 * 60 * 1000).processedPourInterval).toBe(2));
});
