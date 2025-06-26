{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        gopls = {
          enable = true;
          filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
        };
        lua_ls.enable = true;
      };
    };

    plugins.lsp-format.enable = true;
  };
}
