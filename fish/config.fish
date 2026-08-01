source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
set -gx LANG en_IN.UTF-8
set -gx LC_ALL en_IN.UTF-8

# simutil
fish_add_path /home/albert/.local/lib/simutil

fish_add_path /home/albert/.spicetify
