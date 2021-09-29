#!/bin/bash

source _common.sh
source /usr/share/yunohost/helpers

#=================================================
# META HELPER FOR PACKAGE RELEASES
#=================================================

# This script is meant to be manually run by the app packagers
# to automatically update the source files.
# Edit version numbers in _common.sh before running the script.

prepare_source () {
    # Declare an array to define the options of this helper.
    local legacy_args=tda
    local -A args_array=( [t]=template= [d]=destination= [a]=architecture= )
    local template
    local destination
    local architecture
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    local template_path

    if [ -f "../conf/$template" ]; then
        template_path="../conf/$template"
    elif [ -f "../settings/conf/$template" ]; then
        template_path="../settings/conf/$template"
    elif [ -f "$template" ]; then
        template_path=$template
    else
        ynh_die --message="The provided template $template doesn't exist"
    fi

    cp "$template_path" "$destination"

    checksum="__CHECKSUM__"
    ynh_replace_vars --file="$destination"

    local filename
    local checksum
    local url

    # Create the temporary directory
    tempdir="$(mktemp -d)"

    url=$(grep "SOURCE_URL=" "$destination" | cut -d "=" -f 2)
    echo $url
    filename=${url##*/}
    echo $filename
    curl -s -4 -L $url -o "$tempdir/$filename"
    checksum=$(sha256sum "$tempdir/$filename" | head -c 64)

    ynh_secure_remove $tempdir

    ynh_replace_vars --file="$destination"

    echo "$destination updated"
}

for architecture in "${supported_architectures[@]}"; do
	prepare_source --template="../conf/app.src.default" --destination="../conf/app.$architecture.src" --architecture="$architecture"
done

sed -i "s#    \"version\": \".*#    \"version\": \"${version}\~ynh1\",#" ../manifest.json

git add .
git commit ../manifest.json ../conf/app.*.src -m "Upgrade to v$version"
