{
  unify.nixos = {
    environment.etc."pam.d/system-auth".text = ''
      password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok
    '';
  };
}
