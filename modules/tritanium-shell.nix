inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (inputs) self;
  inherit (pkgs.hostPlatform) system;

  # Name that the systemd service for the bar will use.
  service-name = "tritanium-shell";
  cfg = config.services.tritanium-shell;

  hexColorType = lib.mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: lib.isString x && !(lib.hasPrefix "#" x) && builtins.match "^[0-9A-Fa-f]{6}$" x != null;
  };
  mkHexColorOption =
    default:
    lib.mkOption {
      type = lib.types.coercedTo lib.types.str (lib.removePrefix "#") hexColorType;
      inherit default;
      example = default;
      description = "An individual colour of the tritanium-shell theme.";
    };
in
{
  options.services.tritanium-shell = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable tritanium-shell. Does not automatically start the bar in your window manager.
      '';
    };

    package = mkOption {
      type = types.package;
      default = self.packages.${system}.tritanium-shell;
      defaultText = lib.literalExpression "inputs.tritanium-shell.packages.\${system}.tritanium-shell";
      description = ''
        The tritanium-shell package to use.
      '';
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      visible = false;
      description = ''
        The resulting tritanium-shell package.
      '';
    };

    theme.colors = {
      primary = mkHexColorOption "#94e2d5";
      text = mkHexColorOption "#cdd6f4";
      background0 = mkHexColorOption "#181825";
      background1 = mkHexColorOption "#1e1e2e";
      surface0 = mkHexColorOption "#313244";
    };

    settings = {
      vertical = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Vertical layout. Moves bar to the left and quicksettings popup to the bottom left.
        '';
      };

      animations = {
        activeWorkspace = mkOption {
          type = types.enum [
            "simple"
            "smooth"
          ];
          default = "smooth";
          example = "simple";
          description = lib.mdDoc ''
            The animation to display when changing the active workspace on the current monitor.
            - **simple:** only animate the old and new active workspace indicators.
            - **smooth:** run through all intermediate workspace indicators until reaching the new
              active indicator.
          '';
        };
      };

      bar.modules = {
        statusIndicators.batteryPercentage = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Shows the current battery percentage in the bar. Set to false to disable. The battery
            percentage is never shown if no battery is detected.
          '';
        };
        workspacesIndicator.reverseScrollDirection = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Reverse the scroll direction of the workspaces indicator, for all you natural
            scrollling users.
          '';
        };
      };

      lockCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = lib.literalExpression "\${pkgs.hyprlock}/bin/hyprlock --immediate";
        description = ''
          The command used to lock the screen. Set to null to disable.
        '';
      };

      minWorkspaces = mkOption {
        type = types.int;
        default = 3;
        example = 10;
        description = ''
          The minimum amount of workspaces to show regardless of if they are empty or not.
        '';
      };

      popups = {
        volumePopup.enable = mkOption {
          type = types.bool;
          default = true;
          example = true;
          description = ''
            When true, shows a small indicator popup whenever the default speaker volume changes.
          '';
        };
      };
    };

    integrations = {
      hyprland.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, autostarts the bar when hyprland launches.
        '';
      };

      stylix.enable = mkOption {
        type = types.bool;
        default = config.stylix.enable or false;
        description = ''
          If enabled, uses the stylix color scheme to style the bar.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # The systemd user service that is in charge of running the bar. It needs to be manually started
    # by your desktop environment.
    systemd.user.services.${service-name} = {
      Unit = {
        Description = "Tritanium Shell";
        Documentation = "https://github.com/AndreasHGK/tritanium-shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        ExecStart = "${cfg.finalPackage}/bin/tritanium-shell";
        Restart = "on-failure";
        KillMode = "mixed";
      };
    };

    wayland.windowManager.hyprland = lib.mkIf cfg.integrations.hyprland.enable {
      settings = {
        exec-once = [
          "systemctl --user start ${service-name}"
        ];
      };
    };

    xdg.configFile = {
      "tritanium-shell/settings.json".text = builtins.toJSON cfg.settings;
    };

    services.tritanium-shell.finalPackage =
      let
        generateThemeScss = colors: ''
          \$primary: #${colors.primary};
          \$text: #${colors.text};
          \$background0: #${colors.background0};
          \$background1: #${colors.background1};
          \$surface0: #${colors.surface0};
        '';

        colors =
          if cfg.integrations.stylix.enable && config.stylix.enable then
            let
              stylixColors = config.lib.stylix.colors;
            in
            {
              primary = stylixColors.base0C;
              text = stylixColors.base05;
              background0 = stylixColors.base00;
              background1 = stylixColors.base01;
              surface0 = stylixColors.base02;
            }
          else
            cfg.theme.colors;

        agsConfig = pkgs.stdenvNoCC.mkDerivation {
          name = "ags-config";
          src = ../ags;
          allowSubstitutes = false;
          buildPhase = "true";
          installPhase = ''
            mkdir -p $out
            cp -r . $out
            echo "${generateThemeScss colors}" > $out/theme.scss
          '';
        };
      in
      cfg.package.override {
        inherit agsConfig;
      };
  };
}
