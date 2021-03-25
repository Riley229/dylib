#!bin/bash

# command help message
function dylib-manager-help() {
    echo "Manager Commands:"
    echo -e "\tadd"
    echo -e "\tremove"
    echo ""
}

# subcommands
subcommand=$1
case $subcommand in
    "" | "--help")
	dylib-manager-help
	;;
    *)
	shift
	"$workDir/commands/manager_commands/dylib_manager_$subcommand.sh" $@ 2> /dev/null
	if [ $? = 127 ]; then
	    dylib-log "'$subcommand' is not a dylib manager command. See 'dylib manager --help'."
	    exit 1
	else
	    source "$workDir/commands/manager_commands/dylib_manager_$subcommand.sh" $@
	fi
	;;
esac
