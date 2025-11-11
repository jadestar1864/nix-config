{
  configurations.nixos.thinkpadx1.module = {
    disk-layout = {
      disk0 = "/dev/nvme0n1";
      enableSwap = true;
      swapSize = 4;
      enableDiscards = true;
    };
  };
}
