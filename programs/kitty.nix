{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono NL Nerd Font";
      size = 10;
    };
    settings = {
      confirm_os_window_close = 0;
      tab_bar_style = "powerline";
    };
    shellIntegration.enableZshIntegration = true;
    keybindings = {
      "ctrl+j" = "send_text all \\x1b\\x5b\\x42";
      "ctrl+k" = "send_text all \\x1b\\x5b\\x41";
      "ctrl+h" = "send_text all \\x1b\\x5b\\x44";
      "ctrl+l" = "send_text all \\x1b\\x5b\\x43";
    };
  };
}
