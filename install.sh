#!/bin/sh

cd "$(dirname "$0")"

PREFIX=${PREFIX:-"/usr"}
BIN_DIR=${BIN_DIR:-"$PREFIX/bin"}
SHARE_DIR=${SHARE_DIR:-"$PREFIX/share/tinc-create-config/"}

mkdir -p "$DESTDIR/$BIN_DIR"
mkdir -p "$DESTDIR/$SHARE_DIR/"

install_script () {
    sed \
	-e 's|\(export SHARE_DIR\)=.*$|\1='"$SHARE_DIR"'|'
#	-e 's|^\(VERSION\)=.*$|\1='"$VERSION"'|'
}

install_script \
    < tinc-create-config \
    > "$DESTDIR/$BIN_DIR/tinc-create-config"
chmod +x "$DESTDIR/$BIN_DIR/tinc-create-config"

cp -R config-template "$DESTDIR/$SHARE_DIR"
