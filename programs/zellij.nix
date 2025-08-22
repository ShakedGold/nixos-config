{...}: {
  programs.zellij = {
    settings = {
      theme = "default";
    };
    enableZshIntegration = true;
    exitShellOnExit = true;
  };
}
