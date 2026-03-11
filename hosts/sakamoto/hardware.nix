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

  # amdgpu
  hardware.amdgpu = {
    opencl.enable = true;
  };

  boot = {
    # use swap less often
    kernel.sysctl."vm.swappiness" = 10;
    # fix amdgpu driver's screen artefacting: https://www.reddit.com/r/framework/comments/1rbz9vh/screen_artifacts_on_fw_16/
    kernelParams = [ "amdgpu.dcdebugmask=0x410" ];
  };

}
