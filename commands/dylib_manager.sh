#!bin/bash

# command help message
function dylib-manager-help() {
    echo "Manager Commands:"
    echo -e "\tadd                   Starts a dialog for adding new projects to the dylib catalog"
    echo -e "\tremove [projectName]  Starts a dialog for removing the specified project name from the dylib catalog"
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
	    echo "dylib: '$subcommand' is not a dylib manager command. See 'dylib manager --help'."
	    exit 1
	else
	    source "$workDir/commands/manager_commands/dylib_manager_$subcommand.sh" $@
	fi
	;;
esac
