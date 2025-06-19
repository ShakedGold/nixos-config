{
  pkgs,
  ...
} :
let
  tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-super-fingers";
      version = "unstable-2023-01-06";
      src = pkgs.fetchFromGitHub {
        owner = "artemave";
        repo = "tmux_super_fingers";
        rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
        sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
      };
    };
  tmux-easy-motion = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-easy-motion";
      version = "";
      src = pkgs.fetchFromGitHub {
        owner = "IngoMeyer441";
        repo = "tmux-easy-motion";
        rev = "3e2edbd0a3d9924cc1df3bd3529edc507bdf5934";
        sha256 = "sha256-wOIPq12OqqxLERKfvVp4JgLkDXnM0KKtTqRWMqj4rfs=";
      };
    };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs;
      [
        {
          plugin = tmux-super-fingers;
          extraConfig = "set -g @super-fingers-key f";
        }
        {
          plugin = tmux-easy-motion;
          extraConfig = "set -g @easy-motion-prefix \"Space\"";
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = '' 
          set -g @catppuccin_flavour 'frappe'
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_date_time "%H:%M"
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
          '';
        }
        tmuxPlugins.better-mouse-mode
      ];
    extraConfig = ''
        bind -n -N "Split the pane into two, left and right" M-s split-window -h
        bind -n -N "Split the pane into two, top and bottom" M-v split-window -v

        bind -n -N "Kill the current pane" M-x kill-pane

        bind -n -N "Move to the right pane" M-l select-pane -R
        bind -n -N "Move to the left pane" M-h select-pane -L
        bind -n -N "Move to the up pane" M-k select-pane -U
        bind -n -N "Move to the down pane" M-j select-pane -D

        bind -n -N "Resize right" M-L resize-pane -R 5
        bind -n -N "Resize left" M-H resize-pane -L 5
        bind -n -N "Resize up" M-K resize-pane -U 5
        bind -n -N "Resize down" M-J resize-pane -D 5

        bind -n -N "Select the next window" M-n next
        bind -n -N "Select the previous window" M-p prev

        bind -n -N "Create a new window" M-m new-window

        set -g escape-time 0
   '';
  };
}
