stty_orig=`stty -g`
stty -echo
cd ${HOME}/projects
echo "Your ip-address for this cluster is $(hostname -i), please record this so that the instructor can reboot you machine if needed." >&2
stty $stty_orig

