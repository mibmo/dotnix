settings: { inputs, pkgs, ... }:
let
  imports = [
    (import ./wms/gnome.nix settings)
    (import ./syncthing settings)
    ./ipfs
    ./gaming
  ];

  hmImports = [
    inputs.nur.hmModules.nur
    inputs.hyprland.homeManagerModules.default
    hmMore
    (import ./git settings)
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
      htop = {
        enable = true;
        settings.tree_view = true;
      };
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
    ffmpeg
    imv
    neofetch
    wireguard-tools

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
    mpv
    zathura
    #libreoffice
    chromium

    # gaming
    lutris
    mangohud
    wine
    prismlauncher
  ];
in
{
  inherit imports;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${settings.user.name} = {
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
