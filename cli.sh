#!bin/bash

export rootDir="$(cd $(dirname $0) && pwd)/sources"

function entryPoint() {
    # Locate the correct command to execute by looking through the source directory
    # for folders and files which match the arguments provided on the command line.
    commandFile=$rootDir
    commandArgument=1

    # if first argument is '--version', display version
    if [[ "$1" == "--version" ]]; then
	if [[ -f "$rootDir/.version" ]]; then
	    echo "$(cat "${rootDir}/.name") version $(cat "${rootDir}/.version")"
	else
	    echo "$(cat "${rootDir}/.name") has no listed version"
	fi
	exit 0
    fi

    # If user provides help as an argument, show them the help for that command
    for argument in "$@"; do
	if [[ "$argument" == "--help" || "$argument" == "-h" ]]; then
	    help $@
	    exit 3
	fi
    done
    
    while [[ -d "$commandFile/${!commandArgument}" || -f "$commandFile/${!commandArgument}" ]] && [[ $commandArgument -le $# ]]; do
	commandFile="$commandFile/${!commandArgument}"
	((commandArgument+=1))
    done

    # get the remaining arguments for the command
    commandArguments=("${@:commandArgument}")

    # If we hit a directory by the time we run out of arguments, then our user
    # hasn't completed their command, so we'll show them the help for that directory
    # to help them along.
    if [ -d "$commandFile" ]; then
	help "$@"
	exit 3
    fi

    # Run the command and capture its exit code for introspection
    . "$commandFile" "${commandArguments[@]}"
    exitCode=$?

    # If the command exited with an exit code of 3 (our "show help" code)
    # then show the help documentation for the command.
    if [[ $exitCode == 3 ]]; then
	help "$@"
    fi

    # Exit with the same code as the command
    exit $exitCode
}

# generates a help menu for the given commands (everything that appears before `--help`)
function help() {
    # locate command level of arguments to display help for: either a directory with no
    # further arguments, or a command file.
    helpFile=$rootDir
    helpArgument=1
    while [[ -d "$helpFile/${!helpArgument}" || -f "$helpFile/${!helpArgument}" ]] && [[ $helpArgument -le $# ]]; do
	helpFile="$helpFile/${!helpArgument}"
	((helpArgument+=1))
    done

    if [[ $helpArgument == 1 ]]; then
	commandName="$(cat "$rootDir/.name")"
    else
	commandName="$(basename "$helpFile")"
    fi
    # If a helpfile exists for the directory, print a list of available commands
    # along with help message (if included).
    if [[ -d $helpFile ]]; then
	# If there's a help file available for this directory, then display it.
	if [[ -f "$helpFile/.help" ]]; then
	    echo -n "$commandName: "
	    cat "$helpFile/.help"
	    echo -e "\n"
	else
	    echo -e "$commandName\n"
	fi

	echo "Commands:"

	commands=()
	commandUsages=()
	commandHelps=()
	# for each subcommand file, output command
	for file in "$helpFile"/*; do
	    command=$(basename "$file")

	    # if file has a suffix (is a hidden file), then don't show it
	    if [[ "$command" != .* && "$command" != *.* ]]; then
		commands+=( "     $command" )
		if [[ -f "$file.usage" ]]; then
		    commandUsages+=( "$(cat "$file.usage")" )
		elif [[ -d "$file" ]]; then
		    commandUsages+=( "[<subcommand>...]" )
		else
		    commandUsages+=( "" )
		fi
		if [[ -f "$file.help" ]]; then
		    commandHelps+=( "$(cat "$file.help")" )
		elif [[ -f "$file/.help" ]]; then
		    commandHelps+=( "$(cat "$file/.help")" )
		else
		    commandHelps+=( "" )
		fi
	    fi
	done

	# calculate column widths
	commandWidth=0
	for command in "${commands[@]}"; do
	    [[ ${#command} -gt commandWidth ]] && commandWidth=${#command}
	done
	((commandWidth+=1))
	
	usageWidth=0
	for commandUsage in "${commandUsages[@]}"; do
	    [[ ${#commandUsage} -gt usageWidth ]] && usageWidth=${#commandUsage}
	done
	((usageWidth+=1))

	# output commands and command usages in 2 seperate columns
	paste -d '' <(printf "%-${commandWidth}.${commandWidth}s\n" "${commands[@]}") <(printf "%-${usageWidth}.${usageWidth}s\n" "${commandUsages[@]}") <(printf "%s\n" "${commandHelps[@]}")
	echo ""
	exit 0
    fi

    # helpFile must be a file; display help file if available
    if [[ -f "$helpFile.help" ]]; then
	echo -n "$commandName: "
	cat "$helpFile.help"
	echo -e "\n"
    else
	echo -e "$commandName\n"
    fi

    # display usage if available
    if [[ -f "$helpFile.usage" ]]; then
	echo -n "Usage: $commandName "
	cat "$helpFile.usage"
	echo -e "\n"
    fi
}

entryPoint $@
