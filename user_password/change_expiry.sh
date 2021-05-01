mapfile -t names < <( getent passwd {1000..6000} | awk -F: '{ print $1}' )
for n in "${names[@]}"
do
    sudo change -M 60 "$n"
done