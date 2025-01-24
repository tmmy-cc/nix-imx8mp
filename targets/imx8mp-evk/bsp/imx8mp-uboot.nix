{ pkgs
, stdenv
, lib
, bison
, dtc
, fetchgit
, flex
, bc
, openssl
, python312
, python312Packages
, buildPackages
, enable-tee
}:
let
  ubsrc = fetchgit {
      url = "https://github.com/phytec/u-boot-phytec.git";
      # branch: "v2024.01-phy4"
      rev = "8c7a6525b138d45b0dddf1129703fd879efeb15f";
      sha256 = "sha256-vAhwzylJ4FGWKvWgcHpbvWk+mKoYb1/jjqmviNUaM9k=";
    };
  fw-ver = "202006";
  imx8mp-firmware = pkgs.callPackage ./imx8mp-firmware.nix {};
  imx8mp-atf = pkgs.callPackage ./imx8mp-atf.nix {
    inherit (pkgs) buildArmTrustedFirmware;
    inherit enable-tee;
  };
  imx8mp-optee-os = pkgs.callPackage ./imx8mp-optee-os.nix {};

  cp-tee =
    if enable-tee
    then "install -m 0644 ${imx8mp-optee-os}/tee.bin ./tee.bin"
    else "";
in
  (stdenv.mkDerivation {
    pname = "imx8mp-uboot";
    version = "2024.01-phy4";
    src = ubsrc;

    postPatch = ''
      patchShebangs tools
      patchShebangs scripts
    '';

    nativeBuildInputs = [
      bison
      flex
      bc
      dtc
      openssl
      python312
      python312Packages.libfdt
      python312Packages.setuptools
    ];

    depsBuildBuild = [ buildPackages.stdenv.cc ];
    hardeningDisable = [ "all" ];
    enableParallelBuilding = true;

    makeFlags = [
      "DTC=${lib.getExe buildPackages.dtc}"
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ];

    extraConfig = ''
      CONFIG_USE_BOOTCOMMAND=y
      CONFIG_BOOTCOMMAND="setenv ramdisk_addr_r 0x45000000; setenv fdt_addr_r 0x44000000; run distro_bootcmd; "
      CONFIG_CMD_BOOTEFI_SELFTEST=y
      CONFIG_CMD_BOOTEFI=y
      CONFIG_EFI_LOADER=y
      CONFIG_BLK=y
      CONFIG_PARTITIONS=y
      CONFIG_DM_DEVICE_REMOVE=n
      CONFIG_CMD_CACHE=y
    '';

    passAsFile = [ "extraConfig" ];

    configurePhase = ''
      runHook preConfigure

      make phycore-imx8mp_defconfig
      cat $extraConfigPath >> .config

      install -m 0644 ${imx8mp-firmware}/firmware/ddr/synopsys/lpddr4_pmu_train_1d_dmem_${fw-ver}.bin ./lpddr4_pmu_train_1d_dmem_${fw-ver}.bin
      install -m 0644 ${imx8mp-firmware}/firmware/ddr/synopsys/lpddr4_pmu_train_1d_imem_${fw-ver}.bin ./lpddr4_pmu_train_1d_imem_${fw-ver}.bin
      install -m 0644 ${imx8mp-firmware}/firmware/ddr/synopsys/lpddr4_pmu_train_2d_dmem_${fw-ver}.bin ./lpddr4_pmu_train_2d_dmem_${fw-ver}.bin
      install -m 0644 ${imx8mp-firmware}/firmware/ddr/synopsys/lpddr4_pmu_train_2d_imem_${fw-ver}.bin ./lpddr4_pmu_train_2d_imem_${fw-ver}.bin
      install -m 0644 ${imx8mp-atf}/bl31.bin ./bl31.bin
      ${cp-tee}

      runHook postConfigure
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      install -m 0644 ./u-boot-nodtb.bin $out
      install -m 0644 ./spl/u-boot-spl.bin $out
      install -m 0644 ./arch/arm/dts/imx8mp-phyboard-pollux-rdk.dtb $out
      install -m 0644 .config $out
      install -m 0644 ./flash.bin $out

      runHook postInstall
    '';

    dontStrip = true;
  })
