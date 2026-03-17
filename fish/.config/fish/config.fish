# Remove the default Fish welcome message
set -g fish_greeting

# Load Pywal colors for your Sands theme
if test -f ~/.cache/wal/sequences
    cat ~/.cache/wal/sequences
end

# Initialize Starship prompt
starship init fish | source

# System Update (Pacman + AUR/Yay)
abbr -a upd 'yay -Syu'

# Sicherheit
abbr -a rm 'rm -i'

# Hyprland Config schnell öffnen
abbr -a hyprconf 'nano ~/.config/hypr/hyprland.conf'

# Fish Config schnell öffnen & laden
abbr -a fishconf 'nano ~/.config/fish/config.fish'
abbr -a reload 'source ~/.config/fish/config.fish'

