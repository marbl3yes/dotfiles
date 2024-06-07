#!/bin/bash

if test -d "$@"; then
	eza --tree --color=always --icons=always --git "$@" | head -200
else
	bat -n --color=always "$@"
fi
