# git-broker: eigener Systemnutzer, der den SSH-Schlüssel der Agents hält. Den Schlüssel lädt ein
# ssh-agent; in den Container kommt nur dessen Socket (Proxy-Device in incus.nix). Die Agents können
# damit klonen, pushen und Commits signieren, an den Schlüssel selbst kommen sie nicht: ssh-agent
# signiert nur, er gibt Schlüssel nie heraus.
#
# Schlüssel einmalig anlegen (den Nutzer gibt es nach dem ersten Rebuild):
#   sudo -u git-broker ssh-keygen -t ed25519 -N "" -C agent-git -f /var/lib/git-broker/agent-git
#   sudo systemctl start git-broker-ssh-agent
#   sudo cat /var/lib/git-broker/agent-git.pub
# Den öffentlichen Schlüssel eintragen:
#   GitHub → Settings → SSH and GPG keys: zweimal, als "Authentication Key" und als "Signing Key"
#   Forgejo → Einstellungen → SSH-Schlüssel, danach "Verifizieren". Den angezeigten Befehl mit
#     sudo -u git-broker ssh-keygen -Y sign -n gitea -f /var/lib/git-broker/agent-git
#   signieren, sonst zeigt Forgejo die Signaturen nicht als gültig an
# In kein authorized_keys eines Nodes eintragen, der Schlüssel ist nur für Git.
{ pkgs, ... }:

let
  s = import ./settings.nix;

  loadKey = pkgs.writeShellScript "git-broker-load-key" ''
    # ssh-agent legt den Socket erst kurz nach dem Start an
    for _ in $(seq 50); do
      [ -S "$SSH_AUTH_SOCK" ] && break
      sleep 0.1
    done
    exec ${pkgs.openssh}/bin/ssh-add ${s.keyFile}
  '';
in
{
  users.users.git-broker = {
    isSystemUser = true;
    group = "git-broker";
    home = "/var/lib/git-broker";
    createHome = true; # Modus 700, nur git-broker (und root) kommen an den Schlüssel
  };
  users.groups.git-broker = { };

  systemd.services.git-broker-ssh-agent = {
    description = "ssh-agent mit dem Git-Schlüssel der Agents";
    wantedBy = [ "multi-user.target" ];
    # Ohne Schlüssel gar nicht erst starten (statt fehlzuschlagen), siehe oben
    unitConfig.ConditionPathExists = s.keyFile;
    environment.SSH_AUTH_SOCK = s.hostAgentSocket;

    serviceConfig = {
      User = "git-broker";
      Group = "git-broker";
      # /run/git-broker, gehört git-broker. Der Socket selbst ist 0600; Incus verbindet sich als root
      RuntimeDirectory = "git-broker";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a ${s.hostAgentSocket}";
      ExecStartPost = loadKey;
      Restart = "on-failure";

      # ssh-agent braucht nur seinen Socket: kein Netz, Dateisystem nur lesend
      PrivateNetwork = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };
}
