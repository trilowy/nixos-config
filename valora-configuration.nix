{
  inputs,
  ...
}: {
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ./valora-hardware-configuration.nix
    ./common.nix
  ];

  networking.hostName = "valora";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "trilowy" ];
  # Fix "VirtualBox can't operate in VMX root mode"
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
}
