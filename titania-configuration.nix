{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ./titania-hardware-configuration.nix
    ./common.nix
  ];

  networking.hostName = "titania";

  # Nvidia RTX 3070
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  # Gaming
  programs = {
    steam.enable = true;
  };

  # 3D printing
  # environment = {
  #   systemPackages = with pkgs; [
  #     bambu-studio
  #   ];
  # };
}
