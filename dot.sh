#!/bin/sh

: ${DOT_REPO_DIR:=$HOME/Projects/dotfiles}
progname="${0##*/}"

die () {
	echo "$progname: $1" >&2
	exit 1
}

warn () {
	echo "$progname: $1" >&2
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
			git diff "$repofile" "$homefile"
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
			mkdir -p "${homefile%/*}"
			cp "$repofile" "$homefile"
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
			cp "$homefile" "$repofile"
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
			cp "$repofile" "$homefile"
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
