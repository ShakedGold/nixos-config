{
  programs.nixvim = {
    plugins.comment = {
      enable = true;

      settings = {
        toggler = {
          line = "<leader>/";
        };
        opleader = {
          line = "<leader>/";
        };
      };
    };
  };
}
