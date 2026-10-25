# system/sound.nix – Ton über PipeWire.
# Lautstärke-Tasten & Anzeige: home/audio.nix

{ ... }:

{
  security.rtkit.enable = true; # Echtzeit-Priorität gegen Knackser
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # für 32-Bit-Spiele
    pulse.enable = true; # Kompatibilität für PulseAudio-Apps
    wireplumber.enable = true;
  };
}
