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
abbr -a niriconf 'nano ~/dotfiles/niri/.config/niri/config.kdl'
abbr -a kittyconf 'nano ~/.config/kitty/kitty.conf' 

# Fish Config schnell öffnen & laden
abbr -a fishconf 'nano ~/.config/fish/config.fish'
abbr -a reload 'source ~/.config/fish/config.fish'

abbr -a l 'ls'

# fd
abbr -a f fd
abbr -a fa 'fd -IH'

# nmap
abbr -a scan 'nmap -sC -sV -T4 -oA nmap/initial'

# zoxide
zoxide init fish --cmd cd | source

# fastfetch
if status is-interactive
	fastfetch
end
