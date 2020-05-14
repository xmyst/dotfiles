#!/bin/sh

: ${REPO:=$HOME/Projects/dotfiles}
progname="${0##*/}"


die () {
	echo "$progname: $1" >&2
	exit 1
}

usage () {
	echo "usage: $progname {diff|install|pick|update} <item>..." >&2
	exit 0
}


diff () {
	git diff "$@"
}

install () {
	test -r "$1" || die "cannot read file '$1'"
	test -e "$2" && die "file '$2' already exists"

	mkdir -p "${2%/*}"
	cp "$1" "$2"
}

pick () {
	test -r "$2" || die "cannot read file '$2'"

	cp "$2" "$1"
}

update () {
	test -r "$1" || die "cannot read file '$1'"
	test -w "$2" || die "cannot write file '$2'"

	cp "$1" "$2"
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

for item
do
	while read repo home
	do
		$cmd "$REPO/$repo" "$HOME/$home"
	done <"$REPO/$item/manifest"
done
