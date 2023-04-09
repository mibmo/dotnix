user: { inputs, pkgs, ... }:
let
  imports = [
    ./wms/gnome.nix
    (import ./syncthing user)
    ./steam
  ];

  hmImports = [
    inputs.nur.hmModules.nur
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
    insomnia
    obs-studio
    ffmpeg
    mpv
    imv
    imv
    neofetch
    #libreoffice

    # gaming
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

  services.firefox-syncserver.singleNode.enable = true;
}
