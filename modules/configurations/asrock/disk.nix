{
  configurations.nixos.asrock.module = {
    disk-layout = {
      disk0 = "/dev/nvme0n1";
      disk1 = "/dev/nvme1n1";
      enableSwap = true;
      swapSize = 4;
      enableDiscards = true;
    };
  };
}
