import { existsSync } from 'node:fs';
const required = ['dist/main/app.js', 'dist/main/preload.js', 'dist/renderer/index.html'];
for (const path of required) if (!existsSync(path)) throw new Error(`Missing desktop artifact: ${path}`);
console.log(`Desktop smoke: ${required.length} packaged inputs present.`);
