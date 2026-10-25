# home/waybar/system-stats.nix – CPU, RAM und Grafikkarte.
# Klick öffnet btop (Systemmonitor) in einem schwebenden Fenster.

{ lib, pkgs, osConfig, ... }:

let
  nvidia-smi = "${osConfig.hardware.nvidia.package.bin}/bin/nvidia-smi";

  # Auslastung, Temperatur und Speicher der Grafikkarte
  gpu-status = pkgs.writeShellApplication {
    name = "gpu-status";
    runtimeInputs = [ pkgs.gawk ];
    text = ''
      if ! out=$(${nvidia-smi} --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name \
                   --format=csv,noheader,nounits 2>/dev/null); then
        echo '{"text": "–", "tooltip": "Grafikkarte nicht erreichbar"}'
        exit 0
      fi
      awk -F', ' '{
        class = ($1 >= 90) ? "critical" : (($1 >= 60) ? "warning" : "normal")
        printf "{\"text\": \"%s%%\", \"class\": \"%s\", \"tooltip\": \"%s\\nAuslastung %s %%\\nTemperatur %s °C\\nGrafikspeicher %.1f / %.1f GiB\"}\n",
          $1, class, $5, $1, $2, $3 / 1024, $4 / 1024
      }' <<<"$out"
    '';
  };

  monitor = "kitty --class btop btop";
in
{
  programs.waybar.settings.main = {
    cpu = {
      format = "  {usage}%";
      interval = 3;
      states = {
        warning = 70;
        critical = 90;
      };
      on-click = monitor;
    };

    memory = {
      format = "  {percentage}%";
      interval = 5;
      tooltip-format = "{used:0.1f} von {total:0.1f} GiB belegt";
      states = {
        warning = 75;
        critical = 90;
      };
      on-click = monitor;
    };

    "custom/gpu" = {
      exec = lib.getExe gpu-status;
      return-type = "json";
      interval = 5;
      format = "󰢮  {}";
      on-click = monitor;
    };
  };
}
