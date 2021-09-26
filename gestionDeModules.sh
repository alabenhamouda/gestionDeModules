user=${SUDO_USER:-$USER}
home=$(eval echo "~$user")
file="${home}/.removed_modules"
get_modules () {
	lsmod | cut -d " " -f 1 | tail -n +2 | while read module
	do
		description=$(modinfo $module | sed -n '/^description:/p; s/description: / /' | sed 's/^description: //' | sed ':a;N;$!ba;s/\n/, /g')
		if [ ! -z "$description" ]
		then
			# echo -e $module '\t\t' $description
			printf "%-35s\t%s\n" "$module" "$description"
		fi
	done
}
print_nicely () {
	echo -e "$1" | nl | less
}
remove_module () {
	echo "press any key to view the list of modules and select the line number of module you want to remove:"
	read -n 1
	echo 
	output=$(get_modules)
	print_nicely "$output"
	echo "enter the line of the module you wanna remove:"
	read number
	module=$(echo -e "$output" | sed -n "${number}p" | cut -f 1)
	if egrep "^${module}$" $file
	then
		echo "module already removed - nothing to do"
	else
		if modprobe -rf $module
		then
			echo $module >> $file
			echo "module removed"
		fi
	fi
}
insert_module () {
	if [[ -s $file ]]
	then
		echo "Here's the list of removed modules:"
		nl $file
		read -p "enter the number of the line of the module to insert: "
		module=$(sed -n "${REPLY}p" $file)
		if modprobe $module
		then
			sed -i "${REPLY}d" $file
			echo "module inserted successfully"
		fi
	else
		echo "There are no previsouly removed modules"
	fi
}
echo "What do you want to do
1- remove module
2- insert previously removed module"
read
case $REPLY in
	1)
		remove_module
		;;
	2)
		insert_module
		;;
esac
