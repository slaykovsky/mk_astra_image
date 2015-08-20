#!/usr/bin/env bash
#
# Create a base Astra Linux Docker image.
#
#

set -ex

usage() {
	cat <<EOOPTS
	$(basename $0) <name>
	ACHTUNG:
	You need to specify name of resulting tarboll.
EOOPTS
	exit 1
}

apt_sources=/etc/apt/sources.list

# we have to do a little fancy footwork to make sure "rootfsDir" becomes the second non-option argument to debootstrap

shift $((OPTIND -1))
name=$1

if [[ -z $name ]]; then
	usage
fi

# get path to "chroot" in our current PATH
chrootPath="$(type -P chroot)"

target=$(mktemp -d --tmpdir $(basename $0).XXXXXXXX)

mkdir -m 755 "$target"/dev
mknod -m 600 "$target"/dev/console c 5 1
mknod -m 600 "$target"/dev/initctl p
mknod -m 666 "$target"/dev/full c 1 7
mknod -m 666 "$target"/dev/null c 1 3
mknod -m 666 "$target"/dev/ptmx c 5 2
mknod -m 666 "$target"/dev/random c 1 8
mknod -m 666 "$target"/dev/tty c 5 0
mknod -m 666 "$target"/dev/tty0 c 4 0
mknod -m 666 "$target"/dev/urandom c 1 9
mknod -m 666 "$target"/dev/zero c 1 5

debootstrap orel "$target" http://mirror.yandex.ru/astra/current/orel/repository

rm -rf "$target"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
#  docs
rm -rf "$target"/usr/share/{man,doc,info,gnome/help}
#  cracklib
rm -rf "$target"/usr/share/cracklib
#  i18n
rm -rf "$target"/usr/share/i18n
#  sln
rm -rf "$target"/sbin/sln
#  ldconfig
rm -rf "$target"/etc/ld.so.cache
rm -rf "$target"/var/cache/ldconfig/*

cd "$target"

tar --numeric-owner -cf /root/"$name".tar .

rm -rf "$target"