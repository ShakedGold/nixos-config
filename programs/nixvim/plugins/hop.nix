{
  programs.nixvim = {
    plugins.hop = {
      enable = true;

      settings.keys = "asdghklqwertyuiopzxcvbnmfj";
      keymaps = [
        {
          key = "f";
          action.__raw = ''
            function()
              local hop = require('hop')
              hop.hint_words()
            end
          '';
          options.remap = true;
        }
      ];
    };
  };
}
