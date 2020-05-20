#!/bin/sh

: ${DOT_REPO_DIR:=$HOME/src/dotfiles}
progname="${0##*/}"
sysname=$(uname | tr "[:upper:]" "[:lower:]")

die () {
	echo "$progname: $@" >&2
	exit 1
}

warn () {
	echo "$progname: $@" >&2
}

usage () {
	echo "usage: $progname {diff|install|pick|update} [<item>...]" >&2
	exit 0
}

cmd_diff () {
	for item
	do
		while read repofile homefile
		do
			repofile="$DOT_REPO_DIR/$repofile"
			homefile="$HOME/$homefile"
			reposysfile="$repofile.$sysname"
			cat "$repofile" "$reposysfile" 2>/dev/null | git diff --no-index - "$homefile"
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_install () {
	for item
	do
		while read repofile homefile
		do
			repofile="$DOT_REPO_DIR/$repofile"
			homefile="$HOME/$homefile"
			if test -e "$homefile"
			then
				warn "file '$homefile' already exists. Skipping."
				continue
			fi
			reposysfile="$repofile.$sysname"
			mkdir -p "${homefile%/*}"
			cat "$repofile" "$reposysfile" >"$homefile" 2>/dev/null
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_pick () {
	for item
	do
		while read repofile homefile
		do
			repofile="$DOT_REPO_DIR/$repofile"
			homefile="$HOME/$homefile"
			# At least `dirname "$repofile"` should exist,
			# we are reading the manifest from there.
			if ls "$repofile".* 2>/dev/null >&2
			then
				warn "file '$repofile' has system-specific part(s)."
				warn "\tThose are not supported yet. Skipping."
			else
				cp "$homefile" "$repofile"
			fi
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_update () {
	for item
	do
		while read repofile homefile
		do
			repofile="$DOT_REPO_DIR/$repofile"
			homefile="$HOME/$homefile"
			if test ! -w "$homefile"
			then
				warn "cannot write file '$homefile'. Skipping."
				continue
			fi
			reposysfile="$repofile.$sysname"
			cat "$repofile" "$reposysfile" >"$homefile" 2>/dev/null
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

case "$1" in
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
