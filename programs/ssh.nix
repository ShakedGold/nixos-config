let 
  onePassPath = "~/.1password/agent.sock";
in {
programs.ssh = {
  enable = true;
  # Disable default options by setting them to false
  matchBlocks = {
    "*" = {
      extraOptions = {
        "IdentityAgent" = onePassPath;
      };
    };
    "shaked-mac" = {
      hostname = "192.168.1.148";
      user = "shakedgold";
      extraOptions = {
        "IdentityAgent" = onePassPath;
      };
    };
  };
};
}
