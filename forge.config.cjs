module.exports = {
  packagerConfig: { asar: true, icon: undefined, extraResource: ['dist/native/tiddly-frontmost'] },
  makers: [{ name: '@electron-forge/maker-zip', platforms: ['darwin'] }]
};
