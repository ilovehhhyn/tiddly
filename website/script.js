const shell = document.querySelector('.demo-shell');
const pet = document.querySelector('.demo-pet');
const output = document.querySelector('#flow-output');
const track = document.querySelector('.demo-track i');
const note = document.querySelector('.demo-note');
const bubble = document.querySelector('.demo-bubble');
let flow = 26;
let chosenPet = 'hedgehog';
let busy = false;

function setFlow(next) {
  flow = Math.max(0, Math.min(100, next));
  output.textContent = flow;
  track.style.width = `${flow}%`;
}

function setPet(name) {
  chosenPet = name;
  pet.className = `demo-pet sprite ${name === 'owl' ? 'owl-idle' : 'hedgehog-rest'}`;
  pet.setAttribute('aria-label', `${name[0].toUpperCase()}${name.slice(1)} companion`);
  document.querySelectorAll('[data-pet]').forEach(button => {
    button.classList.toggle('active', button.dataset.pet === name);
  });
  bubble.textContent = name === 'owl' ? 'Wise choice.' : 'Tiny business!';
}

async function pour(kind) {
  if (busy) return;
  busy = true;
  shell.classList.add('animating', `animating-${kind}`);
  bubble.textContent = kind === 'wine' ? 'To the next idea!' : 'Hydration nation!';
  note.textContent = kind === 'wine' ? 'Momentum goes up.' : 'A good moment to breathe.';
  setFlow(flow + (kind === 'wine' ? 11 : -9));
  await new Promise(resolve => setTimeout(resolve, 1200));
  shell.classList.remove('animating', `animating-${kind}`);
  setPet(chosenPet);
  busy = false;
}

document.querySelectorAll('[data-pet]').forEach(button => button.addEventListener('click', () => setPet(button.dataset.pet)));
document.querySelector('.wine-pour').addEventListener('click', () => pour('wine'));
document.querySelector('.water-pour').addEventListener('click', () => pour('water'));

document.querySelector('.copy-command').addEventListener('click', async event => {
  const command = 'git clone https://github.com/ilovehhhyn/tiddly.git\ncd tiddly\nnpm install\nnpm start';
  try {
    await navigator.clipboard.writeText(command);
    event.currentTarget.textContent = 'copied!';
  } catch {
    event.currentTarget.textContent = 'select text';
  }
});
