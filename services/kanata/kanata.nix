{
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
         config = builtins.readFile ./kanata.kbd;
      };
    };
  };
}
