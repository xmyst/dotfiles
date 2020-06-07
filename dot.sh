#!/bin/sh

: ${DOT_REPO_DIR:=$HOME/src/dotfiles}
progname=${0##*/}
sysname=$(uname | tr "[:upper:]" "[:lower:]")

die () {
	echo "$progname: $@" >&2
	exit 1
}

usage () {
	echo "usage: $progname {diff|install|pick|update} [<item>...]" >&2
	exit 0
}

warn () {
	echo "$progname: $@" >&2
}

# foreach <expr> [<item>...] -- eval <expr> for each file of each <item>
foreach () {
	expr=$1
	shift

	for item
	do
		while read repofile homefile
		do
			repofile="$DOT_REPO_DIR/$repofile"
			homefile="$HOME/$homefile"
			reposysfile="$repofile.$sysname"
			eval "$expr"
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_diff () {
	foreach '
		# If the file is not available, consider the entire item
		# as not installed.
		if test -r "$homefile"
		then
			cat "$repofile" "$reposysfile" 2>/dev/null |
			git diff --no-index - "$homefile"
		fi
	' "$@"
}

cmd_install () {
	foreach '
		if test -e "$homefile"
		then
			warn "file '"'\$homefile'"' already exists. Skipping."
			continue
		fi
		mkdir -p "${homefile%/*}"
		cat "$repofile" "$reposysfile" >"$homefile" 2>/dev/null
	' "$@"
}

cmd_pick () {
	foreach '
		# At least `dirname $repofile` should exist if we
		# are reading the manifest from it.

		if ls "$repofile".* >/dev/null 2>/dev/null
		then
			warn "file '"'\$repofile'"' has system-specific part(s)."
			warn "\tThose are not supported. Skipping."
			continue
		fi
		cp "$homefile" "$repofile"
	' "$@"
}

cmd_update () {
	foreach '
		if test ! -w "$homefile"
		then
			warn "cannot write file '"'\$homefile'"'. Skipping."
			continue
		fi
		cat "$repofile" "$reposysfile" >"$homefile" 2>/dev/null
	' "$@"
}

case $1 in
diff|install|pick|update)
	cmd=$1
	shift
	;;
"")
	usage
	;;
*)
	die "unknown command '$1'"
	;;
esac

if test $# -eq 0
then
	# Simulate the semantics of "$@".
	allitems=$(basename -a $(ls -d "$DOT_REPO_DIR"/*/))
	cmd_$cmd $allitems
else
	cmd_$cmd "$@"
fi
