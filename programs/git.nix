{
  programs.git = {
    enable = true;

    settings = {
      user = {
        email = "shakedgold2005@gmail.com";
        name = "Shaked Gold";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };

    ignores = [
      "shell.nix"
      "compile_commands.json"
    ];
  };
}
