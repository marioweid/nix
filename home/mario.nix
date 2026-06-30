   { pkgs, lib, ... }:

   let
     commonShellAliases = {
       rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
       rebuild-test = "sudo nixos-rebuild test --flake ~/nixos-config#nixos";
       flake-update = "nix flake update ~/nixos-config";
       nix-gc = "sudo nix-collect-garbage -d";
       cfg = "cd ~/nixos-config";

       # Modern/shiny replacements.
       cat = "bat";
       ls = "eza --icons --group-directories-first";
       ll = "eza -lah --icons --group-directories-first";
       la = "eza -a --icons --group-directories-first";
       lt = "eza --tree --level=2 --icons";
       tree = "eza --tree --icons";
       du = "dust";
       df = "duf";
       ps = "procs";
       ping = "gping";
       ff = "fastfetch";
       fm = "yazi";
     };
   in

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
                                                                                                                                                                                                                    
     # Keep Bash usable, but immediately hand interactive sessions to Zsh.
     # This helps old terminal sessions/apps that still launch Bash.
     programs.bash = {
       enable = true;
       shellAliases = commonShellAliases;
       initExtra = ''
         if [[ $- == *i* ]] && [[ -z "$ZSH_VERSION" ]] && command -v zsh >/dev/null 2>&1; then
           exec zsh
         fi
       '';
     };

     programs.zsh = {
       enable = true;
       enableCompletion = true;
       autocd = true;
       shellAliases = commonShellAliases;
       initContent = lib.mkMerge [
         (lib.mkBefore ''
           # Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
           if [[ -r "$HOME/.cache/p10k-instant-prompt-$USER.zsh" ]]; then
             source "$HOME/.cache/p10k-instant-prompt-$USER.zsh"
           fi
         '')
         ''
           export ATUIN_CONFIG_DIR="$HOME/.config/atuin"

           # Prompt/theme + quality-of-life plugins.
           source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
           # Lean preset: no colored powerline "chips", just a clean text prompt.
           source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-lean.zsh"
           source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
           source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

           # Atuin's Zsh integration is enabled below via programs.atuin.
         ''
       ];
     };

     home.sessionVariables = {
       ATUIN_CONFIG_DIR = "$HOME/.config/atuin";
     };

     programs.atuin = {
       enable = true;
       enableBashIntegration = false;
       enableZshIntegration = true;
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

     programs.fzf = {
       enable = true;
       enableZshIntegration = true;
     };

     programs.zoxide = {
       enable = true;
       enableZshIntegration = true;
       options = [ "--cmd" "cd" ];
     };

     programs.firefox.enable = true;

     # Default to dark mode for GNOME/GTK apps.
     gtk = {
       enable = true;
       gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
       gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
     };

     dconf.settings = {
       "org/gnome/desktop/interface" = {
         color-scheme = "prefer-dark";
         gtk-theme = "Adwaita-dark";
       };

       # Free Super+Space from GNOME's input-source switcher.
       "org/gnome/desktop/wm/keybindings" = {
         switch-input-source = [];
         switch-input-source-backward = [];
       };

       # macOS Spotlight-like launcher on Super+Space.
       "org/gnome/settings-daemon/plugins/media-keys" = {
         custom-keybindings = [
           "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/"
         ];
       };
       "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher" = {
         name = "Ulauncher";
         command = "${pkgs.ulauncher}/bin/ulauncher-toggle";
         binding = "<Super>space";
       };
     };

     xdg.configFile."autostart/ulauncher.desktop".text = ''
       [Desktop Entry]
       Type=Application
       Name=Ulauncher
       Exec=${pkgs.ulauncher}/bin/ulauncher --hide-window
       X-GNOME-Autostart-enabled=true
     '';

     programs.git = {
       enable = true;
       settings = {
         user = {
           name = "Mario";
           email = "mario.weidner@gmx.de";
         };
         init.defaultBranch = "main";
         push.autoSetupRemote = true;
       };
     };

     programs.kitty = {
       enable = true;
       font = {
         name = "JetBrainsMono Nerd Font";
         size = 12;
       };
       themeFile = "Catppuccin-Mocha";
       shellIntegration = {
         enableBashIntegration = false;
         enableZshIntegration = true;
       };
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
         shell = "${pkgs.zsh}/bin/zsh";
         window_padding_width = 6;
       };
     };

     home.packages = with pkgs; [
       pi-coding-agent

       # Modern terminal tools
       bat
       dua
       duf
       dust
       eza
       fastfetch
       fd
       gping
       piper
       procs
       ripgrep
       tree
       ulauncher
       yazi

       nerd-fonts.jetbrains-mono
     ];                                                                                                                                                                                                             
   } 
