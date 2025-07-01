{
  programs.git = {
    enable = true;
    userName = "Shaked Gold";
    userEmail = "shakedgold2005@gmail.com";
    extraConfig.init.defaultBranch = "main";
    extraConfig.push.autoSetupRemote = true;
    ignores = [
      "shell.nix"
      "compile_commands.json"
    ];
  };
}
