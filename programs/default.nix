user: { inputs, pkgs, ... }:
let
  imports = [
    (import ./wms/gnome.nix user)
    (import ./syncthing user)
    ./steam
    ./ipfs
  ];

  hmImports = [
    inputs.nur.hmModules.nur
    inputs.hyprland.homeManagerModules.default
    hmMore
    (import ./git user)
    ./fish
    ./neovim
    ./alacritty
    ./firefox
  ];
  hmMore = { ... }: {
    xdg.userDirs = {
      desktop = ".desktop";
      documents = "assets/documents";
      download = "download";
      music = "assets/music";
      pictures = "assets/pictures";
      templates = ".templates";
      publicShare = ".publicShare";
    };

    programs = {
      gpg.enable = true;
      fzf.enable = true;
      htop.enable = true;
      bottom.enable = true;
    };
  };

  includedPkgs = with pkgs; [
    gnumake
    which
    mktemp
    wl-clipboard
    killall
    any-nix-shell # shell support for nix
    duf # nicer df
    libqalculate
    ldns # dns utility

    # nix
    nix-index

    # security
    keepassxc

    # audio stuff
    pulsemixer
    easyeffects

    # chat
    element-desktop
    jitsi-meet-electron

    # misc
    gimp
    krita
    blender
    prusa-slicer
    kicad
    freecad
    solvespace
    insomnia
    obs-studio
    ffmpeg
    mpv
    imv
    neofetch
    #libreoffice
    chromium

    # gaming
    lutris
    wine
    osu-lazer
    prismlauncher
  ];
in
{
  inherit imports;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.name} = {
      news.display = "silent";
      imports = hmImports;
      home = {
        stateVersion = "22.11";
        packages = includedPkgs;
        sessionVariables = {
          EDITOR = "nvim";
        };
      };
    };
  };
}
