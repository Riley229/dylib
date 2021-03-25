#!bin/bash

. $catalog

# Generates manifest file content given a target file and list of dependencies
function generate-manifest() {
    targetFile=$1
    shift
    dependencies=( "$@" )

    > $targetFile
    
    for dependency in "${dependencies[@]}"; do
	dependencyVersion=${dependency}_libraryVersion
	echo -e "$dependency \t ${!dependencyVersion}" >> $targetFile
    done
}
