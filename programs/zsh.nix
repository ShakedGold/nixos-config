{
  config,
  lib,
  pkgs,
  ...
}: let
  prompt = pkgs.writers.writeBash "prompt" ''
    get_git_nix_prompt2() {
      local nix_prompt=""
      if [ -n "$IN_NIX_SHELL" ]; then
        # Nerd Font icon U+F313 with correct coloring
        nix_prompt="%{$fg[red]%}[%{$fg_bold[white]%}nix-shell %{$fg[cyan]%} %{$reset_color%}%{$fg[red]%}]"
      fi

      if git rev-parse --is-inside-work-tree &> /dev/null || [ -n "$IN_NIX_SHELL" ]; then
        echo -n "%}%(?,,%{$fg[red]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[red]%}])"
        echo -n "$nix_prompt"
        echo -n "
    %{$fg[red]%}└"
      fi
    }

    get_git_nix_prompt1() {
      if git rev-parse --is-inside-work-tree &> /dev/null || [ -n "$IN_NIX_SHELL" ]; then
        echo -n "%{$fg[red]%}┌"
      fi
    }

    PROMPT=$'$(get_git_nix_prompt1)$(git_prompt_info)$(get_git_nix_prompt2)%{$fg[red]%}[%{$fg_bold[white]%}%~%{$reset_color%}%{$fg[red]%}]>%{$reset_color%} '
    PS2=$' %{$fg[red]%}|>%{$reset_color%} '

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}[%{$fg_bold[white]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[red]%}] "
    ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}⚡%{$reset_color%}"
  '';
in {
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
      btop = "LANG=en_US.UTF-8 btop"; # fix no locale
      g = "git";
      tmux = "tmux -u";
      x = ". $HOME/.zshrc";
      nix-shell = "export NIX_SHELL=1; nix-shell";
      c = "wl-copy";
      v = "wl-paste";
    };

    envExtra = ''
      ZSH_TMUX_FIXTERM_WITH_256COLOR=true
      ZSH_TMUX_UNICODE=true
      echo 'eval "$(zellij setup --generate-auto-start zsh)"'
    '';

    initContent = ''
      [[ "$TERM" == "xterm-kitty" ]] && export TERM=xterm-256color
      ${lib.concatMapStrings (x: "${toString x}\n") (
        lib.mapAttrsToList (name: value: "export ${name}=${toString value}") config.home.sessionVariables
      )}
      source ${prompt}

      [[ ! -d /tmp/.nvim-undo-dir ]] && mkdir /tmp/.nvim-undo-dir

      fastfetch
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "tmux"
      ];
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
  };
}
