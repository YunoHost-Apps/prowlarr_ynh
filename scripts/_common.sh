#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

version="0.8.1.2135"

# Supported architectures
supported_architectures=("arm" "arm64" "x64")

# dependencies used by the app
pkg_dependencies="curl mediainfo sqlite3"

#=================================================
# PERSONAL HELPERS
#=================================================

get_architecture() {
	architecture=$(dpkg --print-architecture)
	if [ $architecture = "amd64" ]; then
		architecture="x64"
	elif [[ $architecture = arm* ]] && [[ $(getconf LONG_BIT) = 32 ]]; then
		architecture="arm"
	elif [[ $architecture = arm* ]] && [[ $(getconf LONG_BIT) = 64 ]]; then
		architecture="arm64"
	elif [[ $(echo ${supported_architectures[@]} | grep -ow "$architecture" | wc -w) = 0 ]]; then
		ynh_die --message="Unsupported architecture $architecture"
	fi
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
