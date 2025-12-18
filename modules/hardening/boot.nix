{
  unify.nixos = {
    boot.loader.systemd-boot.editor = false;

    boot.kernelParams = [
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "pti=on"
      "vsyscall=none"
      "debugfs=off"
      "oops=panic"
      "quiet"
      "loglevel=0"
      "random.trust_cpu=off"
    ];
  };
}
