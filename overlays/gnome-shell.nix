self: super: {
  gnome = super.gnome.overrideScope' (gself: gsuper: {
    gnome-shell = gsuper.gnome-shell.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (super.fetchpatch { # copying screenshots to clipboard without saving to file as well
          url = "https://gitlab.gnome.org/djasa/gnome-shell/-/commit/9e4fb9d583fbb4c724206532dd16344f3685df37.patch";
          hash = "sha256-epjzjILyD8/qrfQUoAJt8Jem8lQaPs+mrR8sEUoJ5jc=";
        })
      ];
    });
  });
}
