{
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      cat = "bat";
      ls = "eza --icons=always";
      pcat = "bat --style plain";
    };

    initExtra = ''
      [[ "$TERM" == "xterm-kitty" ]] && export TERM=xterm-256color
      ${lib.concatMapStrings (x: "${toString x}\n") (lib.mapAttrsToList(name: value: "export ${name}=${toString value}") config.home.sessionVariables)}
      source ${config.home.homeDirectory}/.config/home-manager/custom-zsh-theme.zsh-theme
    '';

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck"];
    };
  };

}
