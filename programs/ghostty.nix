{
  pkgs,
  ...
} : {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;

    installVimSyntax = true;
    enableZshIntegration = true;

    settings = {
      font-family = "JetBrainsMono Nerd Font";
      background = "#000000";
      background-opacity = 0.9;
      background-blur = true;
      confirm-close-surface = false;
    };
  };
}
