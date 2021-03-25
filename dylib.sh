#!bin/bash

# A simple function for creating more professional cli output
function dylib-log() {
    file=${0##*/}
    name=${file%%.sh}
    echo "$name: $1"
}

# get the working directory and declare 'global' content
export workDir=$(cd $(dirname $0) && pwd)
export catalog="$workDir/dylib.catalog"
export -f dylib-log

# command help message
function dylib-help() {
    echo "dylib provides basic tools which simplify the usage of Merlin dynamic libraries."
    echo ""
}

# subcommands
subcommand=$1
case $subcommand in
    "" | "--help")
	dylib-help
	;;
    "--version")
	echo "dylib version $(cat $workDir/VERSION)"
	;;
    *)
	shift
	"$workDir/commands/dylib_$subcommand.sh" $@ 2> /dev/null
	if [ $? = 127 ]; then
	    dylib-log "'$subcommand' is not a dylib command. See 'dylib --help'."
	    exit 1
	else
	    source "$workDir/commands/dylib_$subcommand.sh" $@
	fi
	;;
esac
