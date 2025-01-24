{pkgs, ...} @ args:
with pkgs;
  buildLinux (args
    // rec {
      version = "6.6.21-phy1";
      name = "imx8mp-linux";

      # modDirVersion needs to be x.y.z, will automatically add .0 if needed
      #modDirVersion = version;
      modDirVersion = "6.6.21";

      defconfig = "defconfig";

      kernelPatches = [
      ];

      autoModules = false;

      extraConfig = ''
        CRYPTO_TLS m
        TLS y
        MD_RAID0 m
        MD_RAID1 m
        MD_RAID10 m
        MD_RAID456 m
        DM_VERITY m
        LOGO y
        FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER n
        FB_EFI n
        EFI_STUB y
        EFI y
        VIRTIO y
        VIRTIO_PCI y
        VIRTIO_BLK y
        DRM_VIRTIO_GPU y
        EXT4_FS y
        USBIP_CORE m
        USBIP_VHCI_HCD m
        USBIP_HOST m
        USBIP_VUDC m
      '';

      src = fetchFromGitHub {
        owner = "phytec";
        repo = "linux-phytec";
        # tag: v6.6.21-phy1
        rev = "2da1b824a19ac245cf9cec36ebf6a76bbeb23839";
        sha256 = "sha256-fmN81KtmAU6WGWZKWaIvqfnlx+4l+OCPvDBVxVQpkco=";
      };
    }
    // (args.argsOverride or {}))
