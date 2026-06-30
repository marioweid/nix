   { pkgs, ... }:                                                                                                                                                                                                   
                                                                                                                                                                                                                    
   {                                                                                                                                                                                                                
     home.username = "mario";                                                                                                                                                                                       
     home.homeDirectory = "/home/mario";                                                                                                                                                                            
                                                                                                                                                                                                                    
     home.stateVersion = "26.05";                                                                                                                                                                                   
                                                                                                                                                                                                                    
     programs.neovim = {                                                                                                                                                                                            
       enable = true;                                                                                                                                                                                               
       defaultEditor = true;                                                                                                                                                                                        
       viAlias = true;                                                                                                                                                                                              
       vimAlias = true;                                                                                                                                                                                             
     };                                                                                                                                                                                                             
                                                                                                                                                                                                                    
     programs.bash = {
       enable = true;
       shellAliases = {
         rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
         rebuild-test = "sudo nixos-rebuild test --flake ~/nixos-config#nixos";
         flake-update = "nix flake update ~/nixos-config";
         nix-gc = "sudo nix-collect-garbage -d";
         cfg = "cd ~/nixos-config";
         ll = "ls -alF";
       };
       initExtra = ''
         # Force Atuin to use the Home Manager config directory before running
         # `atuin init`; old sessions may still inherit ATUIN_CONFIG_DIR=/etc/atuin.
         export ATUIN_CONFIG_DIR="$HOME/.config/atuin"

         source "${pkgs.bash-preexec}/share/bash/bash-preexec.sh"

         # No --disable-up-arrow here: Up Arrow opens Atuin history search.
         eval "$(${pkgs.atuin}/bin/atuin init bash)"
       '';
     };

     home.sessionVariables = {
       ATUIN_CONFIG_DIR = "$HOME/.config/atuin";
     };

     programs.atuin = {
       enable = true;
       enableBashIntegration = false;
       settings = {
         auto_sync = true;
         sync_frequency = "5m";
         sync_address = "https://api.atuin.sh";
         search_mode = "fuzzy";
         # Show all saved history when pressing Up, including commands from
        # previous terminal sessions/reboots. "session" only shows commands
        # from the current shell, which looks like history was lost after restart.
        filter_mode_shell_up_key_binding = "global";
       };
     };                                                                                                                                                                                                             
                                                                                                                                                                                                                    
     programs.firefox.enable = true;

     programs.git = {
       enable = true;
       settings = {
         user = {
           name = "Mario";
           email = "mario.weidner@gmx.de";
         };
         init.defaultBranch = "main";
       };
     };

     programs.kitty = {
       enable = true;
       font = {
         name = "JetBrainsMono Nerd Font";
         size = 12;
       };
       themeFile = "Catppuccin-Mocha";
       shellIntegration.enableBashIntegration = true;
       keybindings = {
         "ctrl+tab" = "next_tab";
         "ctrl+shift+tab" = "previous_tab";
         "ctrl+t" = "new_tab";
         "ctrl+shift+t" = "new_tab";
         "ctrl+shift+w" = "close_tab";
       };
       settings = {
         confirm_os_window_close = 0;
         cursor_shape = "beam";
         enable_audio_bell = false;
         hide_window_decorations = "no";
         scrollback_lines = 10000;
         tab_bar_edge = "top";
         tab_bar_style = "powerline";
         window_padding_width = 6;
       };
     };

     home.packages = with pkgs; [
       pi-coding-agent
       ripgrep
       fd
       fzf
       nerd-fonts.jetbrains-mono
     ];                                                                                                                                                                                                             
   } 
