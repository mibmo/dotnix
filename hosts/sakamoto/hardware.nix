{ ... }:

{
  # fix touchpad palm rejection
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Keyboard]
    MatchUdevType=keyboard
    MatchName=Framework Laptop 16 Keyboard Module - ANSI Keyboard
    AttrKeyboardIntegration=internal
  '';

  # prevent wakeup when keyboard flexes in backpack
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"
  '';

  # microcode
  hardware.cpu.amd.updateMicrocode = true;

  # use swap less often
  boot.kernel.sysctl."vm.swappiness" = 10;
}
