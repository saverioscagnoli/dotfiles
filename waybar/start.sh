killall waybar

if [[ $USER = "svscagn" ]] then
    waybar -c ~/dotfiles/waybar/config -s ~/dotfiles/waybar/style.css & 
else
    waybar &
fi