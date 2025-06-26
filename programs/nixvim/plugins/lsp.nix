{
  programs.nixvim = {
    plugins.lsp.enable = true;

    plugins.lsp.autoLoad = true;
    plugins.lsp.servers = {
      lsp-format.enable = true;
      gopls = {
        enable = true;
        filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
      };
    };
  };
}
