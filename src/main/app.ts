import { app, BrowserWindow, ipcMain, Menu, nativeImage, powerMonitor, screen, Tray } from 'electron';
import { join } from 'node:path';
import { applyCountedTime, drinkWater, giveWine, markerX, curveY, POUR_INTERVAL_MS } from './progression';
import { defaultPosition, initialState, PetState, StateStore } from './state-store';
import { SessionClock } from './session-clock';
import { observeCodexForeground } from './activity';
import { AgentBridge } from './bridge';

const PET_WINDOW = { width: 176, height: 176 };
const PANEL_WINDOW = { width: 220, height: 410 };
let window: BrowserWindow;
let tray: Tray;
let state: PetState;
let store: StateStore;
let clock: SessionClock;
let saveTimer: NodeJS.Timeout;
let isQuitting = false;
let bridge: AgentBridge;
let panelOpen = false;
let petPosition: { x: number; y: number } | undefined;
let dragOrigin: { screenX: number; screenY: number; windowX: number; windowY: number; petX?: number; petY?: number } | undefined;

if (!app.requestSingleInstanceLock()) app.quit();

function snapshot() {
  const x = markerX(state);
  return { ...state, markerX: x, markerY: curveY(x), nextPourMs: POUR_INTERVAL_MS - (state.countedMs % POUR_INTERVAL_MS), connection: bridge?.status() ?? { connectedSessions: 0, pending: false, message: 'Agent bridge starting…' } };
}

function sendState() { if (window && !window.isDestroyed()) window.webContents.send('state', snapshot()); }

function createWindow(): void {
  const saved = state.position ?? defaultPosition(PET_WINDOW.width, PET_WINDOW.height);
  window = new BrowserWindow({
    ...PET_WINDOW, ...saved, transparent: true, frame: false, resizable: false,
    alwaysOnTop: true, skipTaskbar: true, hasShadow: false, show: false,
    acceptFirstMouse: true,
    webPreferences: { preload: join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false }
  });
  window.setAlwaysOnTop(true, 'floating');
  window.loadFile(join(__dirname, '../renderer/index.html'));
  window.once('ready-to-show', () => window.showInactive());
  window.on('moved', () => {
    const [x, y] = window.getPosition();
    state.position = panelOpen && petPosition ? petPosition : { x, y };
    store.save(state);
  });
  window.on('close', event => { if (!isQuitting) { event.preventDefault(); window.hide(); } });
  window.webContents.setWindowOpenHandler(() => ({ action: 'deny' }));
}

function setPanelOpen(open: boolean): void {
  const [x, y] = window.getPosition();
  const [width, height] = window.getSize();
  if (!open && petPosition) {
    window.setBounds({ ...petPosition, ...PET_WINDOW }, false);
    panelOpen = false;
    return;
  }

  petPosition = { x, y };
  const work = screen.getDisplayNearestPoint({ x, y }).workArea;
  const desiredX = x + width - PANEL_WINDOW.width;
  const desiredY = y + height - PANEL_WINDOW.height;
  const clampedX = Math.max(work.x, Math.min(desiredX, work.x + work.width - PANEL_WINDOW.width));
  const clampedY = Math.max(work.y, Math.min(desiredY, work.y + work.height - PANEL_WINDOW.height));
  panelOpen = true;
  window.setBounds({ x: clampedX, y: clampedY, ...PANEL_WINDOW }, false);
}

function createTray(): void {
  const icon = nativeImage.createFromDataURL('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAKUlEQVR42mNgGAWjYBSMglEwCkbBKBgFo2AUjIJRMApGwSgYBaNgFIwCAAAEEAABVq8gNwAAAABJRU5ErkJggg==');
  tray = new Tray(icon);
  const rebuild = () => tray.setContextMenu(Menu.buildFromTemplate([
    { label: 'Show pet', click: () => window.showInactive() },
    { label: state.paused ? 'Resume' : 'Pause', click: () => togglePause(rebuild) },
    { type: 'separator' }, { label: 'Quit', click: () => { isQuitting = true; app.quit(); } }
  ]));
  rebuild();
}

function togglePause(after?: () => void): void {
  state.paused = !state.paused; clock.setPaused(state.paused); store.save(state); sendState(); after?.();
}

function hidePet(): void {
  if (panelOpen) setPanelOpen(false);
  window.webContents.send('panel-closed');
  window.hide();
}

app.whenReady().then(() => {
  store = new StateStore(); state = store.load(); clock = new SessionClock(state.countedMs, state.paused);
  bridge = new AgentBridge(
    () => { state = giveWine(state); store.save(state); window.webContents.send('skill-invoked'); sendState(); },
    () => sendState()
  );
  bridge.start();
  createWindow(); createTray();
  ipcMain.handle('snapshot', () => snapshot());
  ipcMain.handle('panel', (_event, open: unknown) => { if (typeof open !== 'boolean') throw new Error('Panel state must be boolean'); setPanelOpen(open); });
  ipcMain.on('pet-menu', () => {
    Menu.buildFromTemplate([{ label: 'Close Pet', click: hidePet }]).popup({ window });
  });
  ipcMain.on('begin-drag', (_event, screenX: unknown, screenY: unknown) => {
    if (typeof screenX !== 'number' || typeof screenY !== 'number') return;
    const [windowX, windowY] = window.getPosition();
    dragOrigin = { screenX, screenY, windowX, windowY, petX: petPosition?.x, petY: petPosition?.y };
  });
  ipcMain.on('drag-to', (_event, screenX: unknown, screenY: unknown) => {
    if (!dragOrigin || typeof screenX !== 'number' || typeof screenY !== 'number') return;
    const dx = screenX - dragOrigin.screenX;
    const dy = screenY - dragOrigin.screenY;
    if (panelOpen && dragOrigin.petX !== undefined && dragOrigin.petY !== undefined) {
      petPosition = { x: Math.round(dragOrigin.petX + dx), y: Math.round(dragOrigin.petY + dy) };
    }
    window.setPosition(Math.round(dragOrigin.windowX + dx), Math.round(dragOrigin.windowY + dy));
  });
  ipcMain.handle('wine', () => { state = giveWine(state); const connection = bridge.arm(); store.save(state); sendState(); return { ...snapshot(), connection }; });
  ipcMain.handle('water', () => { state = drinkWater(state); store.save(state); sendState(); return snapshot(); });
  ipcMain.handle('pause', () => { togglePause(); return snapshot(); });
  ipcMain.handle('cancel-request', () => { bridge.cancel(); sendState(); return snapshot(); });
  ipcMain.handle('character', (_event, id: unknown) => {
    if (id !== 'owl' && id !== 'hedgehog') throw new Error('Unknown character');
    state.characterId = id; store.save(state); sendState(); return snapshot();
  });
  ipcMain.handle('new-session', () => { const kept = { characterId: state.characterId, position: state.position }; state = { ...initialState(), ...kept }; clock = new SessionClock(0, false); store.save(state); sendState(); return snapshot(); });
  const tick = () => { state = applyCountedTime(state, clock.update()); sendState(); };
  const observeActivity = () => observeCodexForeground(eligible => clock.setEligible(eligible));
  observeActivity();
  setInterval(observeActivity, 2_000);
  setInterval(tick, 1000); saveTimer = setInterval(() => store.save(state), 10_000);
  powerMonitor.on('suspend', () => clock.setPaused(true));
  powerMonitor.on('resume', () => clock.setPaused(state.paused));
  screen.on('display-removed', () => { const [width, height] = window.getSize(); const point = defaultPosition(width, height); window.setPosition(point.x, point.y); });
});

app.on('before-quit', () => { isQuitting = true; bridge?.stop(); if (saveTimer) clearInterval(saveTimer); if (store && state) store.save(state); });
app.on('window-all-closed', () => {});
