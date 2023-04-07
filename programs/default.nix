user: { pkgs, ... }:
let
  imports = [
    ./wms/gnome.nix
    (import ./syncthing user)
    ./steam
  ];

  hmImports = [
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
    mktemp
    gnumake
    which
    any-nix-shell # shell support for nix
    killall
    neofetch
    wl-clipboard

    # essentials
    keepassxc

    # audio stuff
    pulsemixer
    easyeffects

    # chat
    element-desktop
    jitsi-meet-electron

    # code
    #rustup
    insomnia

    # graphics
    gimp
    krita
    blender

    # office
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
