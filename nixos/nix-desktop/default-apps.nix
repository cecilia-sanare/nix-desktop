{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  inherit (lib) mkMerge mkOption mkIf types;
  inherit (types) listOf nullOr;
in
{
  options.nix-desktop.default-apps = {
    file-manager = mkOption {
      description = "The default text editor to use";
      type = nullOr (types.str);
      default = if cfg.type == null then null else
      (
        {
          gnome = "nautilus.desktop";
        }.${cfg.type} or null
      );
    };

    browser = mkOption {
      description = "The default browser to use";
      type = types.str;
      default = null;
    };

    video-player = mkOption {
      description = "The default video player to use";
      type = nullOr (types.str);
      default = if cfg.type == null then null else "vlc.desktop";
    };

    document-viewer = mkOption {
      description = "The default document viewer to use";
      type = nullOr (types.str);
      default = null;
    };

    text-editor = mkOption {
      description = "The default text editor to use";
      type = nullOr (types.str);
      default = null;
    };
  };

  config =
    let
      browserMimeTypes = (
        [ "text/html" ]
        ++ lib.lists.forEach [ "http" "https" "about" "unknown" ]
          (x: "x-scheme-handler/" + x)
      );
      videoMimeTypes = [ "video/x-matroska" "video/mp4" ];
      documentTypes = [ "application/pdf" ];
      textTypes = [ "application/json" "text/plain" "text/markdown" ];
      folderTypes = [ "inode/directory" ];
    in
    mkIf (cfg.enable && cfg.default-apps != null) {
      xdg.mime = {
        enable = true;
        defaultApplications = mkMerge [
          (lib.attrsets.genAttrs folderTypes (name: cfg.default-apps.file-manager))
          (lib.attrsets.genAttrs browserMimeTypes (name: cfg.default-apps.browser))
          (lib.attrsets.genAttrs videoMimeTypes (name: cfg.default-apps.video-player))
          (lib.attrsets.genAttrs documentTypes (name: cfg.default-apps.document-viewer))
          (lib.attrsets.genAttrs textTypes (name: cfg.default-apps.text-editor))
        ];
      };
    };
}
