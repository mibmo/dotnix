{ lib, pkgs, config, ... }: {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-lua
      fcitx5-mozc
    ];
  };
  environment = {
    variables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };
    systemPackages = lib.optional
      config.services.xserver.desktopManager.gnome.enable
      pkgs.gnomeExtensions.kimpanel;
  };

  home.settings.home.file =
    let
      format = pkgs.formats.ini { };
    in
    {
      fcitx5-config = {
        target = ".config/fcitx5/config";
        force = true;
        source = format.generate "fcitx5-config" {
          Hotkey = {
            # enumerate when press trigger key repeatedly
            EnumerateWithTriggerKeys = true;
            # enumerate input method forward
            EnumerateForwardKeys = null;
            # enumerate input method backward
            EnumerateBackwardKeys = null;
            # skip first input method while enumerating
            EnumerateSkipFirst = false;
          };
          Behavior = {
            # active by default
            ActiveByDefault = false;
            # share input state
            ShareInputState = "No";
            # show preedit in application
            PreeditEnabledByDefault = true;
            # show input method information when switch input method
            ShowInputMethodInformation = true;
            # show input method information when changing focus
            showInputMethodInformationWhenFocusIn = false;
            # show compact input method information
            CompactInputMethodInformation = true;
            # show first input method information
            ShowFirstInputMethodInformation = true;
            # default page size
            DefaultPageSize = 5;
            # override xkb option
            OverrideXkbOption = false;
            # custom xkb option
            CustomXkbOption = null;
            # force enabled addons
            EnabledAddons = null;
            # force disabled addons
            DisabledAddons = null;
            # preload input method to be used by default
            PreloadInputMethod = true;
            # allow input method in the password field
            AllowInputMethodForPassword = false;
            # show preedit text when typing password
            ShowPreeditForPassword = false;
            # interval of saving user data in minutes
            AutoSavePeriod = 30;
          };

          "Hotkey/TriggerKeys" = {
            "0" = "Control+Shift+space";
            "1" = "Zenkaku_Hankaku";
            "2" = "Hangul";
          };
          "Hotkey/AltTriggerKeys"."0" = "Shift_L";
          "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
          "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
          "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
          "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
        };
      };

      fcitx5-profile =
        let
          defaultLayout = {
            hamilton = "dk";
            macadamia = "dk-mac";
          }.${config.networking.hostName};
        in
        {
          target = ".config/fcitx5/profile";
          force = true;
          source = format.generate "fcitx5-profile" {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = defaultLayout;
              DefaultIM = "mozc";
            };
            "Groups/0/Items/0".Name = "keyboard-${defaultLayout}";
            "Groups/0/Items/1".Name = "mozc";
          };
        };
    };
}
