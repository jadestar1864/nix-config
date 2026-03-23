{
  unify.modules.pc.home = {pkgs, ...}: {
    # TODO: Check if freetube is updated past 0.23.15
    #home.packages = with pkgs; [
    #  freetube
    #];
    services.flatpak.packages = ["io.freetubeapp.FreeTube"];
  };
}
