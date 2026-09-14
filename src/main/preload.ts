import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('tiddly', {
  snapshot: () => ipcRenderer.invoke('snapshot'),
  panel: (open: boolean) => ipcRenderer.invoke('panel', open),
  beginDrag: (screenX: number, screenY: number) => ipcRenderer.send('begin-drag', screenX, screenY),
  dragTo: (screenX: number, screenY: number) => ipcRenderer.send('drag-to', screenX, screenY),
  showPetMenu: () => ipcRenderer.send('pet-menu'),
  wine: () => ipcRenderer.invoke('wine'),
  water: () => ipcRenderer.invoke('water'),
  pause: () => ipcRenderer.invoke('pause'),
  cancelRequest: () => ipcRenderer.invoke('cancel-request'),
  character: (id: 'owl' | 'hedgehog') => ipcRenderer.invoke('character', id),
  newSession: () => ipcRenderer.invoke('new-session'),
  onState: (listener: (state: unknown) => void) => ipcRenderer.on('state', (_event, state) => listener(state)),
  onSkillInvoked: (listener: () => void) => ipcRenderer.on('skill-invoked', listener),
  onPanelClosed: (listener: () => void) => ipcRenderer.on('panel-closed', listener)
});
