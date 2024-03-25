killall waybar

if [[ $USER = "svscagn" ]] then
    waybar -c ~/dotfiles/waybar/config & 
else
    waybar &
fi