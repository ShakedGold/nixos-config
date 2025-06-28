{pkgs, ...}: let
  tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-super-fingers";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "artemave";
      repo = "tmux_super_fingers";
      rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
      sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
    };
  };
in {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      {
        plugin = tmux-super-fingers;
        extraConfig = "set -g @super-fingers-key f";
      }
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'frappe'
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_date_time "%H:%M"
          set -g @catppuccin_window_status_style "rounded"

          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_directory}"
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
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

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

      bind -n -N "Toggle pane fullscreen" M-f resize-pane -Z

      set -g escape-time 0

      set-option -g status-position top

      set -g base-index 1
      set -g renumber-windows

      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      bind P paste-buffer
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
    '';
  };
}
