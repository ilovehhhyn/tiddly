export class SessionClock {
  private baseline = performance.now();
  private eligible = false;

  constructor(private countedMs: number, private paused: boolean) {}

  setPaused(paused: boolean): void {
    this.update();
    this.paused = paused;
    this.baseline = performance.now();
  }

  setEligible(eligible: boolean): void {
    this.update();
    this.eligible = eligible;
  }

  update(): number {
    const now = performance.now();
    const elapsed = now - this.baseline;
    this.baseline = now;
    // Unknown long gaps are never credited; normal renderer stalls remain harmless.
    if (!this.paused && this.eligible && elapsed >= 0 && elapsed < 10_000) this.countedMs += elapsed;
    return this.countedMs;
  }
}
