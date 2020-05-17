#!/bin/sh

: ${DOT_REPO_DIR:=$HOME/Projects/dotfiles}
progname="${0##*/}"

die () {
	echo "$progname: $1" >&2
	exit 1
}

usage () {
	echo "usage: $progname {diff|install|pick|update} [<item>...]" >&2
	exit 0
}

cmd_diff () {
	for item
	do
		while read repopath homepath
		do
			repopath="$DOT_REPO_DIR/$repopath"
			homepath="$HOME/$homepath"
			git diff "$repopath" "$homepath"
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_install () {
	for item
	do
		while read repopath homepath
		do
			repopath="$DOT_REPO_DIR/$repopath"
			homepath="$HOME/$homepath"
			if test ! -r "$repopath"
			then
				echo "cannot read file '$repopath'. Skipping." >&2
				continue
			fi
			if test -e "$homepath"
			then
				echo "file '$homepath' already exists. Skipping." >&2
				continue
			fi
			mkdir -p "${homepath%/*}"
			cp "$repopath" "$homepath"
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_pick () {
	for item
	do
		while read repopath homepath
		do
			repopath="$DOT_REPO_DIR/$repopath"
			homepath="$HOME/$homepath"
			# At least `dirname "$repopath"` should exist,
			# since we can read the manifest from it.
			if ! test -r "$homepath"
			then
				echo "cannot read file '$homepath'. Skipping." >&2
				continue
			fi
			cp "$homepath" "$repopath"
		done <"$DOT_REPO_DIR/$item/manifest"
	done
}

cmd_update () {
	for item
	do
		while read repopath homepath
		do
			repopath="$DOT_REPO_DIR/$repopath"
			homepath="$HOME/$homepath"
			if test ! -r "$repopath"
			then
				echo "cannot read file '$repopath'. Skipping." >&2
				continue
			fi
			if test ! -w "$homepath"
			then
				echo "cannot write file '$homepath'. Skipping." >&2
				continue
			fi
			cp "$repopath" "$homepath"
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
