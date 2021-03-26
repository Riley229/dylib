#!bin/bash

# outputs a debug message passed as a parameter (these messages will not
# be displayed unless parameter 2 is 'true').
function log-debug() {
    message=$1
    debugEnabled=$2
    [[ $debugEnabled == "true" ]] && echo -e $message
}

# outputs a message passed as a parameter.
function log-info() {
    message=$1
    echo -e $message
}

# outputs an error message passed as a parameter (these messages will appear
# in bold red font).
function log-error() {
    redANSI='\033[1;31m'
    noColorANSI='\033[0m'
    message=$1
    echo -e "${redANSI}${message}${noColorANSI}"
}

# Generates a manifest file at the targetDirectory given an array
# of libraries and a cooresponding array of versions
function generate-manifest() {
    targetFile="$1/dylib.manifest"
    local -n _libraries=$2
    local -n _versions=$3
    
    # calculate column width
    columnWidth=0
    for library in "{_libraries[@]}"; do
	[[ ${#library} -gt columnWidth ]] && columnWidth=${#library}
    done
    ((columnWidth+=5))

    # generate file content at targetFile
    paste <(printf "%-${columnWidth}.${columnWidth}s\n" "${_libraries[@]}") <(printf "%s\n" "${_versions[@]}") > $targetFile
}
