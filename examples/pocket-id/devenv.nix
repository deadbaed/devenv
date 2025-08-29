{ pkgs, config, ... }:
{
  packages = [ pkgs.curl ]; # used for the test

  services = {
    pocket-id = {
      enable = true;
      package = pkgs.pocket-id;
      settings = {
        ANALYTICS_DISABLED = true;
        PORT = 1234;
      };
    };
  };
}
