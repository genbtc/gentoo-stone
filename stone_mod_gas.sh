# --- T2-COPYRIGHT-NOTE-BEGIN ---
# T2 SDE: package/*/stone/stone_mod_gas.sh
# Copyright (C) 2004 - 2022 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This Copyright note is generated by scripts/Create-CopyPatch,
# more information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.
# --- T2-COPYRIGHT-NOTE-END ---

select_packages() {
	local namever installed uninstalled

	for (( ; ; )) ; do
		cmd="gui_menu gastone 'Install/Remove packages: $5

Note: any (un)installations are done immediately'"

		installed=""
		uninstalled=""
		for (( i=${#pkgs[@]} - 1; i >= 0; i-- )) ; do
			if echo "${cats[$i]}" | grep -q -F "$5"; then
				namever="${pkgs[$i]}-${vers[$i]}"
				if [ -f $2/var/adm/packages/${pkgs[$i]} ]; then
					cmd="$cmd '[*] $namever' '$packager -r -R $2 ${pkgs[$i]}'"
					installed="$installed ${pkgs[$i]}"
				elif [ -f "$4/$1/pkgs/$namever$ext" ]; then
					cmd="$cmd '[ ] $namever' '$packager -i -R $2 $4/$1/pkgs/$namever$ext'"
					uninstalled="$uninstalled $namever$ext"
				elif [ -f "$4/$1/pkgs/${pkgs[$i]}$ext" ]; then
					cmd="$cmd '[ ] $namever' '$packaher -i -R $2 $4/$1/pkgs/${pkgs[$i]}$ext'"
					uninstalled="$uninstalled ${pkgs[$i]}$ext"
				fi
			fi
		done
		[ "$uninstalled$installed" ] && cmd="$cmd '' ''"
		[ "$uninstalled" ] && \
			cmd="$cmd 'Install all packages marked as [ ]' '(cd $4/$1/pkgs ; $packager -i -R $2 $uninstalled)'"
		[ "$installed" ] && \
			cmd="$cmd 'Uninstall all packages marked as [*]' '$packager -r -R $2 $installed'"

		eval "$cmd" || break
	done
}

main() {
	if ! [ -f $4/$1/pkgs/packages.db ]; then
		gui_message "gas: package database not accessible."
		return
	fi

	if ! [ -d $2 ]; then
		gui_message "gas: target directory not accessible."
		return
	fi

	if [ $2 = "${2#/}" ]; then
		gui_message "gas: target directory not absolute."
		return
	fi

	local packager ext

	if type -p bize > /dev/null && ! type -p mine > /dev/null; then
		packager=bize
		ext=.tar.bz2
	else
		packager=mine
		ext=.gem
	fi

	declare -a pkgs vers cats
	local a b category
	unset package

	while read a b ; do
		if [ "$a" = "[C]" ]; then cats[${#pkgs[@]}]="${cats[${#pkgs[@]}]} $b"
		elif [ "$a" = "[V]" ]; then vers[${#pkgs[@]}]="$b"
		elif [ -z "$b" ]; then
			pkgs[${#pkgs[@]}]="$package"
			vers[${#pkgs[@]}]="0.0"
			cats[${#pkgs[@]}]="all/all"
			package="$a"
		else
			gui_message "gas: invalid package database input '$a $b'."
			return
		fi
	done < <( gzip -d < $4/$1/pkgs/packages.db | grep "^[a-zA-Z0-9_+.-]\+$\|^\[[CV]\]")
	[ "$package" ] && pkgs[${#pkgs[@]}]="$package"

	category="gui_menu category 'Select category'"
	for i in `echo ${cats[@]} | sed -e 's/ /\n/g' | sort -u` ; do
		category="$category $i 'select_packages $1 $2 $3 $4 $i'"
	done
	while eval "$category" ; do : ; done
}
