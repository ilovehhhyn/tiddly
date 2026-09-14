import './styles.css';

const api = window.tiddly;
let state;
let busy = false;
let panelOpen = false;
let pose = 'idle';
const FIVE_HOURS_MS = 5 * 60 * 60 * 1000;
const poses = {
  hedgehog: { wine: ['wine-1'], water: ['water-1', 'water-2'] },
  owl: { wine: ['wine-1', 'wine-2', 'wine-3'], water: ['water-1'] }
};

const app = document.querySelector('#app');
app.innerHTML = `<section class="panel" aria-hidden="true"><div class="panel-content"><header><table class="stats" aria-label="Session metrics"><tbody><tr><td><output class="metric-minutes"></output><span>minutes</span></td><td><output class="metric-wine"></output><span>wine</span></td><td><output class="metric-water"></output><span>water</span></td><td><output class="metric-level"></output><span>level</span></td></tr></tbody></table></header><small class="signature">tiddly</small><div class="chart"><div class="peak-meter"><div class="peak-label"><span>Ballmer peak</span><output></output></div><div class="peak-track"><i></i></div></div><svg class="graph" viewBox="0 0 300 120" role="img"><path class="curve"></path><line class="reference" x1="0" y1="100" x2="300" y2="100"></line><circle class="marker" r="5"></circle><text x="10" y="115">0</text></svg></div><div class="next"></div><div class="actions"><button class="wine drink-button" aria-label="Pour me wine" data-label="pour me wine"><span class="wine-art"><img src="./source/wine-button-original.png" alt="" draggable="false"></span></button><button class="water drink-button" aria-label="Pour me water" data-label="pour me water"><span class="water-art"><img src="./source/water-button-original.png" alt="" draggable="false"></span></button></div><div class="settings"><label>pet <select><option value="hedgehog">hedgehog</option><option value="owl">owl</option></select></label><button class="pause"></button></div><p class="status"></p><button class="cancel hidden">cancel request</button><button class="close" aria-label="Close panel">×</button></div></section><button class="pet" aria-label="Open Tiddly controls"><span class="sprite"></span></button><div class="drink-scene" aria-hidden="true"><i class="drink-step step-1"></i><i class="drink-step step-2"></i><i class="drink-step step-3"></i><i class="drink-step step-4"></i></div><div class="bubble" role="status"></div>`;

const el = name => app.querySelector(`.${name}`);
const panel = el('panel');
const pet = el('pet');
let ignoreNextPetClick = false;
let drag;

function setPanel(open) {
  panelOpen = open;
  panel.classList.toggle('open', open);
  panel.setAttribute('aria-hidden', String(!open));
  void api.panel(open);
}
pet.addEventListener('mousedown', event => {
  if (event.button !== 0) return;
  api.beginDrag(event.screenX, event.screenY);
  drag = { screenX: event.screenX, screenY: event.screenY, moved: false };
});
document.addEventListener('mousemove', event => {
  if (!drag || !(event.buttons & 1)) return;
  const dx = event.screenX - drag.screenX;
  const dy = event.screenY - drag.screenY;
  if (!drag.moved && Math.hypot(dx, dy) < 4) return;
  drag.moved = true;
  api.dragTo(event.screenX, event.screenY);
});
document.addEventListener('mouseup', () => {
  if (!drag) return;
  ignoreNextPetClick = drag.moved;
  drag = undefined;
});
pet.addEventListener('click', () => {
  if (ignoreNextPetClick) { ignoreNextPetClick = false; return; }
  setPanel(!panelOpen);
});
pet.addEventListener('contextmenu', event => {
  event.preventDefault();
  api.showPetMenu();
});
el('close').addEventListener('click', () => setPanel(false));
document.addEventListener('keydown', event => { if (event.key === 'Escape') { setPanel(false); pet.focus(); } });

function pickPose(kind) {
  const choices = poses[state.characterId][kind];
  return choices[Math.floor(Math.random() * choices.length)];
}

async function animate(kind, message) {
  if (busy) return;
  busy = true; pose = pickPose(kind); app.classList.add(`animating-${kind}`); render(); showBubble(message);
  const frames = matchMedia('(prefers-reduced-motion: reduce)').matches
    ? [[4, 350]]
    : [[1, 270], [2, 360], [3, 360], [4, 810]];
  for (const [frame, duration] of frames) {
    app.dataset.drinkFrame = String(frame);
    await new Promise(resolve => setTimeout(resolve, duration));
  }
  delete app.dataset.drinkFrame;
  pose = 'idle'; busy = false; app.classList.remove(`animating-${kind}`); render();
}

function showBubble(message) { const bubble = el('bubble'); bubble.textContent = message; bubble.classList.add('show'); setTimeout(() => bubble.classList.remove('show'), 4200); }
el('wine').addEventListener('click', async () => {
  if (busy) return;
  void animate('wine', '');
  state = await api.wine();
  render();
  panel.classList.remove('peak-advanced');
  void panel.offsetWidth;
  panel.classList.add('peak-advanced');
  setTimeout(() => panel.classList.remove('peak-advanced'), 900);
});
el('water').addEventListener('click', async () => {
  if (busy) return;
  void animate('water', '');
  state = await api.water();
  render();
  panel.classList.remove('peak-retreated');
  void panel.offsetWidth;
  panel.classList.add('peak-retreated');
  setTimeout(() => panel.classList.remove('peak-retreated'), 900);
});
el('pause').addEventListener('click', async () => { state = await api.pause(); render(); showBubble(state.paused ? 'Paused. I’ll save your place.' : 'Back to tiny business.'); });
el('cancel').addEventListener('click', async () => { state = await api.cancelRequest(); render(); });
el('settings').querySelector('select').addEventListener('change', async event => { state = await api.character(event.target.value); render(); });

function formatMinutes(ms) { return `${Math.floor(ms / 60000)}m`; }
function renderGraph() {
  const maxX = Math.max(0.16, Math.ceil(state.markerX / 0.08) * 0.08);
  const maxY = Math.log1p(maxX / 0.13) / Math.log(2);
  const point = x => ({ x: 10 + 280 * x / maxX, y: 100 - 85 * (Math.log1p(x / 0.13) / Math.log(2)) / maxY });
  const samples = Array.from({ length: 41 }, (_, i) => point(maxX * i / 40));
  el('curve').setAttribute('d', samples.map((p, i) => `${i ? 'L' : 'M'}${p.x.toFixed(1)} ${p.y.toFixed(1)}`).join(' '));
  const marker = point(state.markerX); el('marker').setAttribute('cx', marker.x); el('marker').setAttribute('cy', marker.y);
  const referenceY = point(0.13).y;
  el('reference').setAttribute('y1', referenceY);
  el('reference').setAttribute('y2', referenceY);
  el('graph').setAttribute('aria-label', `${formatMinutes(state.countedMs)} counted and ${state.extraWineCount} extra sips; fictional tipsiness ${state.markerX.toFixed(3)}`);
}

function render() {
  if (!state) return;
  app.dataset.character = state.characterId;
  app.dataset.pose = pose === 'idle' && state.characterId === 'owl' && state.countedMs >= FIVE_HOURS_MS ? 'sleepy' : pose;
  el('metric-minutes').textContent = Math.floor(state.countedMs / 60000);
  el('metric-wine').textContent = state.extraWineCount;
  el('metric-water').textContent = state.waterCount;
  el('metric-level').textContent = state.markerX.toFixed(3);
  const peakPercent = Math.round(100 * state.markerX / 0.13);
  el('peak-meter').querySelector('output').textContent = `${peakPercent}%`;
  el('peak-track').querySelector('i').style.width = `${Math.min(100, peakPercent)}%`;
  el('next').textContent = `Next little pour in ${Math.max(1, Math.ceil(state.nextPourMs / 60000))}m`;
  el('pause').textContent = state.paused ? 'Resume' : 'Pause';
  const connectionMessage = /agent tasks seen|starting/i.test(state.connection.message) ? '' : state.connection.message;
  el('status').textContent = connectionMessage;
  el('status').classList.toggle('hidden', !connectionMessage);
  el('cancel').classList.toggle('hidden', !state.connection.pending);
  el('settings').querySelector('select').value = state.characterId;
  el('wine').disabled = busy; el('water').disabled = busy;
  renderGraph();
}

api.onState(next => { const prior = state; state = next; render(); if (prior && next.processedPourInterval > prior.processedPourInterval) animate('wine', next.encouraged && !prior.encouraged ? 'Half an hour. Nice work. Tiny cheers.' : ''); if (prior && next.celebrated && !prior.celebrated) showBubble('Peak little genius. Onward?'); });
api.onSkillInvoked(() => animate('wine', ''));
api.onPanelClosed(() => {
  panelOpen = false;
  panel.classList.remove('open');
  panel.setAttribute('aria-hidden', 'true');
});
state = await api.snapshot(); render();
