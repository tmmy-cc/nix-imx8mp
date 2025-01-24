{
  pkgs,
  enable-tee ? false,
}:
let
  imx8mp-uboot = pkgs.callPackage ./imx8mp-uboot.nix {
    inherit enable-tee;
  };
in {
  imx8m-boot = imx8mp-uboot;
}
