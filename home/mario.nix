   { pkgs, lib, inputs, ... }:

   let
     commonShellAliases = {
       rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
       rebuild-test = "sudo nixos-rebuild test --flake ~/nixos-config#nixos";
       flake-update = "nix flake update --flake ~/nixos-config";
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

       # Make opencode usable
       # opencode = "opencode --auto";
     };

     # Shared shell functions used by both Bash and Zsh.
     commonFunctions = ''
       # Wrap ssh so that inside kitty we use kitty's ssh kitten, which copies
       # the xterm-kitty terminfo to the remote host on connect. Without this,
       # SSH sessions from kitty into machines lacking kitty-terminfo get a
       # broken TERM and keys like Backspace stop working.
       # Outside kitty (or if kitty is missing) we fall back to a plain ssh.
       ssh() {
         if [[ "$TERM" == xterm-kitty ]] && command -v kitty >/dev/null 2>&1; then
           kitty +kitten ssh "$@"
         else
           command ssh "$@"
         fi
       }
     '';
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
       initExtra = commonFunctions + ''
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

           # Shared shell functions (e.g. kitty-aware ssh wrapper).
           ${commonFunctions}

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

     # VSCodium is a community-driven, fully open-source build of VS Code
     # without Microsoft's telemetry/branding and with the open-vsx extension
     # marketplace (see https://nixos.wiki/wiki/VSCodium).
     # Use `programs.vscodium` (not `programs.vscode`) so Home Manager writes
     # settings/extensions to VSCodium's own paths (~/.vscodium, VSCodium/User)
     # instead of the Microsoft VS Code paths.
     # The -fhs variant runs the binary in a fake FHS filesystem so extension
     # dependencies resolve correctly.
     programs.vscodium = {
       enable = true;
       package = pkgs.vscodium-fhs;
       # Add your desired extensions from open-vsx, e.g.:
       # extensions = with pkgs.vscode-extensions; [ bbenoist.nix ms-python.python ];
     };

     # Make the non-Steam Guild Wars shortcut show up in GNOME search.
     xdg.dataFile."applications/guild-wars.desktop".text = ''
       [Desktop Entry]
       Type=Application
       Name=Guild Wars
       Comment=Launch Guild Wars through Steam/Proton
       Exec=steam steam://rungameid/2338494418
       Icon=/home/mario/.local/share/Steam/steamapps/compatdata/2338494418/pfx/drive_c/proton_shortcuts/icons/256x256/apps/2130_Gw.0.png
       Categories=Game;
       StartupNotify=true
       StartupWMClass=gw.exe
     '';

     # Default to dark mode for GNOME/GTK apps.
     gtk = {
       enable = true;
       gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
       gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
     };


     dconf.settings = {
       "org/gnome/shell" = {
         disable-user-extensions = false;
         enabled-extensions = [ "multi-monitors-bar@frederykabryan" ];
       };

       "org/gnome/desktop/interface" = {
         color-scheme = "prefer-dark";
         gtk-theme = "Adwaita-dark";
       };


       # Increase GNOME idle/screen-blank and suspend timeouts so the
       # monitor does not go to sleep so quickly. Times are in seconds.
       "org/gnome/desktop/session" = {
         idle-delay = 900; # blank the screen after 15 minutes of inactivity
       };
       "org/gnome/settings-daemon/plugins/power" = {
         sleep-inactive-ac-timeout = 3600;      # 60 minutes on AC power
         sleep-inactive-ac-type = "suspend";
         sleep-inactive-battery-timeout = 1200; # 20 minutes on battery
         sleep-inactive-battery-type = "suspend";
       };

       # Manually tuned GNOME mouse cursor speed, with acceleration disabled.
       "org/gnome/desktop/peripherals/mouse" = {
         speed = -0.56;
         accel-profile = "flat";
       };

       # Make Super+Space and Alt+Space open GNOME Overview/search, like pressing Super.
       "org/gnome/shell/keybindings" = {
         toggle-overview = [ "<Super>space" "<Alt>space" ];
       };

       # Free Super+Space from GNOME's input-source switcher and Alt+Space from the window menu.
       "org/gnome/desktop/wm/keybindings" = {
         switch-input-source = [];
         switch-input-source-backward = [];
         activate-window-menu = [];
       };

       # Keep GNOME custom shortcuts empty; shortcuts above are configured directly.
       "org/gnome/settings-daemon/plugins/media-keys" = {
         custom-keybindings = [];
       };
     };

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

     # Nix pins the GitHub revision; flake-update advances it and rebuild links it.
     # Use Pi's discovery paths instead of making its mutable settings.json read-only.
     home.file.".pi/agent/skills/agent-skills".source = "${inputs.agentSkills}/skills";
     home.file.".pi/agent/AGENTS.md".source = "${inputs.agentSkills}/standards/AGENTS.md";

     home.packages = with pkgs; [
       pi-coding-agent

       # Modern terminal tools
       bat
       btop
       dua
       duf
       dust
       eza
       fastfetch
       fd
       gping
       discord
       spotify
       procs
       ripgrep
       tree
       uv
       yazi
       nerd-fonts.jetbrains-mono
       teamspeak6-client
       opencode
     ];                                                                                                                                                                                                             
   } 
