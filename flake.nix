{
  description = "NixOS SD card image for nxp-imx8mp-evk with custom kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations = {
      acb = nixpkgs.lib.nixosSystem {
        modules = [
          #nixos-hardware.nixosModules.nxp-imx8mp-evk
          ./targets/imx8mp-evk/default.nix
          #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./modules/hardware/imx8mp-evk/imx8mp-sd-image.nix

          #({config, lib, pkgs, ...}: {
          #  imports = [
          #    "${nixpkgs}/nixos/modules/profiles/base.nix"
          #    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
          #  ];
          #  boot.loader.grub.enable = false;
          #  boot.loader.generic-extlinux-compatible.enable = true;
          #  boot.consoleLogLevel = lib.mkDefault 7;
          #  boot.kernelParams = ["console=ttymxc0,115200n8"];
          #  sdImage = {
          #      #dd if=${pkgs.imx8m-boot}/image/flash.bin of=$img seek=64 conv=notrunc
          #    populateFirmwareCommands = ''
          #    '';
          #    populateRootCommands = ''
          #    '';
          #  };
          #})

          ({config, lib, pkgs, ...}: {
            # Enable cross compilation
            #nixpkgs.buildPlatform = "x86_64-linux";
            #nixpkgs.crossSystem.system = "aarch64-linux";

            hardware.deviceTree.name = lib.mkForce "freescale/imx8mp-phyboard-pollux-rdk.dtb";
            boot.loader.grub.enable = lib.mkDefault false;
            boot.kernelParams = lib.mkForce ["console=ttymxc0,115200n8" "root=/dev/mmcblk0p2"];
            boot.consoleLogLevel = lib.mkDefault 7;
            boot.loader.generic-extlinux-compatible.enable = true;

            #sdImage.compressImage = false;

            networking.useDHCP = true;
            services.openssh.enable = true;

            users.users.myuser = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [ "your-ssh-public-key" ];
            };

            system.stateVersion = "24.11"; # Adjust to your NixOS version
          })
        ];
      };
    };
  };
}

