{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  disabledModules = [(modulesPath + "/profiles/all-hardware.nix")];
  sdImage = {
    compressImage = false;

    #cp ${pkgs.imx8m-boot}/flash.bin firmware/
    populateFirmwareCommands = ''
      mkdir -p $out/firmware
      install -m 0644 ${pkgs.imx8m-boot}/flash.bin $out/firmware/
    '';

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';

    #fwoffset=64
    #blocksize=512
    #fwsize=15920
    #rootoffset=16384
    postBuildCommands = ''
      sdimage="$out/nixos.img"
      fwoffset=64
      blocksize=512
      fwsize=20416
      rootoffset=20480

      sfdisk --list $img | grep Linux
      rootstart=$(sfdisk --list $img | grep Linux | awk '{print $3}')
      rootsize=$(sfdisk --list $img | grep Linux | awk '{print $5}')
      imagesize=$(((rootoffset + rootsize)*blocksize))
      touch $sdimage
      truncate -s $imagesize  $sdimage
      echo -e "
        label: dos
        label-id: 0x2178694e
        unit: sectors
        sector-size: 512

        start=$fwoffset, size=$fwsize, type=60
        start=$rootoffset, size=$rootsize, type=83, bootable" > "$out/partition.txt"
      sfdisk -d $img
      sfdisk $sdimage < "$out/partition.txt"
      dd conv=notrunc if=$out/firmware/flash.bin of=$sdimage seek=$fwoffset
      dd conv=notrunc if=$img of=$sdimage seek=$rootoffset skip=$rootstart count=$rootsize
      sfdisk --list $sdimage
      rm -rf $out/sd-image
    '';
  };
}
