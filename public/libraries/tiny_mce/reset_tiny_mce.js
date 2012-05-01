resetTinyMCE = function () {
  // Remove any Tiny editors from the panel before it's reloaded:
  if (tinyMCE) {
    for (editor in tinyMCE.editors) {
      tinyMCE.execCommand('mceRemoveControl', true, editor);
    }

    tinyMCE.activeEditor = {};
  }
};
