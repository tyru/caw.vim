#!/bin/sh
if command -v nvim >/dev/null; then
	not_a_term=--headless
	vi=nvim
else
	not_a_term=--not-a-term
	vi=vim
fi
$vi -u NONE -i NONE $not_a_term -e -s -N -X -S macros/generate-ftplugins.vim -c quit
