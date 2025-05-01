{
  inputs,
  pkgs,
  ...
} : {
  programs.obs-studio.package = inputs.nixpkgs-obs-nvenc.legacyPackages.${pkgs.system}.obs-studio.override {
    cudaSupport = true;
  };
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-pipewire-audio-capture
  ];
}
