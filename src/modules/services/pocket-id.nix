{ pkgs, config, lib, ... }:
let
  cfg = config.services.pocket-id;
  types = lib.types;
  format = pkgs.formats.keyValue { };
  pocket-id-storage = config.env.DEVENV_STATE + "/pocket-id";
in
{

  options.services.pocket-id = {
    enable = lib.mkEnableOption "Pocket ID server, an OIDC provider (https://pocket-id.org)";

    package = lib.mkOption {
      type = types.package;
      default = pkgs.pocket-id;
      defaultText = lib.literalExpression "pkgs.pocket-id";
      description = "The pocket-id package to use.";
    };

    settings = lib.mkOption {
      type = types.submodule {
        freeformType = format.type;

        options = {
          APP_URL = lib.mkOption {
            type = types.str;
            description = "The URL where you will access the app.";
            default = "http://localhost:1411";
          };

          TRUST_PROXY = lib.mkOption {
            type = types.bool;
            description = "Whether the app is behind a reverse proxy.";
            default = false;
          };

          ANALYTICS_DISABLED = lib.mkOption {
            type = types.bool;
            description = ''
              Disable heartbeat that gets sent every 24 hours to count how many Pocket ID instances are running.

              See [docs page](https://pocket-id.org/docs/configuration/analytics/).
            '';
            default = false;
          };

          DB_PROVIDER = lib.mkOption {
            type = types.enum [ "sqlite" "postgres" ];
            description = "The database provider you want to use. Currently `sqlite` and `postgres` are supported.";
            default = "sqlite";
          };

          # Change default path to store data inside "$DEVENV_STATE/pocket-id"
          DB_CONNECTION_STRING = lib.mkOption {
            type = types.str;
            default = "file:${pocket-id-storage}/pocket-id.db";
            description = "Specifies the connection string used to connect to the database.";
          };

          # Change default path to store data inside "$DEVENV_STATE/pocket-id"
          UPLOAD_PATH = lib.mkOption {
            type = types.path;
            default = "${pocket-id-storage}/uploads";
            description = "The path where the uploaded files are stored.";
          };

          # Change default path to store data inside "$DEVENV_STATE/pocket-id"
          KEYS_PATH = lib.mkOption {
            type = types.path;
            default = "${pocket-id-storage}/keys";
            description = "When `KEYS_STORAGE` is `file`, this is the path where the private keys are stored.";
          };

          # Change default path to store data inside "$DEVENV_STATE/pocket-id"
          GEOLITE_DB_PATH = lib.mkOption {
            type = types.path;
            default = "${pocket-id-storage}/GeoLite2-City.mmdb";
            description = "The path where the GeoLite2 database should be stored.";
          };

        };
      };

      default = { };

      description = ''
        Environment variables that will be passed to Pocket ID, see
        [configuration options](https://pocket-id.org/docs/configuration/environment-variables)
        for supported values.
      '';
    };

  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    env = cfg.settings;

    processes.pocket-id.exec = ''
      mkdir -p ${pocket-id-storage}
      exec "${cfg.package}/bin/pocket-id"
    '';
  };

}
