#!bin/bash

# load contents of catalog file
source $catalog

# get command line argument of project-to-remove's name
if [ "$#" -ne 1 ]; then
    echo "You must enter exactly 1 command line argument:"
    echo -e "\tprojectName"
    exit 1
fi
projectName=$1

echo "Preparing to remove dylib project $projectName..."
echo ""

if [[ " ${libraries[@]} " =~ " ${projectName} " ]]; then
    classification=1
elif [[ " ${projects[@]} " =~ " ${projectName} " ]]; then
    classification=2
else
    echo "Unable to locate dylib project $projectName in dylib catalog."
    echo -e "\tTask aborted"
    exit 1
fi

[[ $classification = 1 ]] && classificationName="library" || classificationName="project"

libraryVersion=${projectName}_libraryVersion
repository=${projectName}_repository
dependencies=${projectName}_dependencies

echo "Project located, are your sure your want to remove the following project?"
echo -e "\tname: $projectName"
echo -e "\tclassification: $classificationName"
if [ $classification == "1" ]; then
    echo -e "\tlibraryVersion: ${!libraryVersion}"
fi
echo -e "\trepository: ${!repository}"
read -p "Enter 'y' or 'n': " confirmation

# cancel if unsure or no response
if [[ "$confirmation" = "n" ]]; then
    echo "Task aborted"
    exit 1
elif [[ "$confirmation" != "y" ]]; then
    echo "You must enter either 'y' or 'n'"
    echo -e "\tTask aborted"
    exit 1
fi

# remove project from dylib catalog
echo "Removing dylib project $projectName from dylib catalog..."

# remove from either projects or libraries depending on classification.
new_array=()
if [ $classification == "1" ]; then
    for library in "${libraries[@]}"; do
	[[ $library != $projectName ]] && new_array+=($library)
    done
    libraries=("${new_array[@]}")
else
    for project in "${projects[@]}"; do
	[[ $project != $projectName ]] && new_array+=($project)
    done
    projects=("${new_array[@]}")
fi
unset new_array

# generate new library and project array strings.
newLibraries="libraries=("
for library in "${libraries[@]}"; do
    newLibraries+=" \"$library\""
done
newLibraries+=" )"

newProjects="projects=("
for project in "${projects[@]}"; do
    newProjects+=" \"$project\""
done
newProjects+=" )"

# replace libraries and projects with new data
sed -i "s/^libraries=(.*/$newLibraries/" $catalog
sed -i "s/^projects=(.*/$newProjects/" $catalog

# remove projects data from file
sed -i "/${projectName}_libraryVersion.*/d" $catalog
sed -i "/${projectName}_repository.*/d" $catalog
sed -i "/${projectName}_dependencies.*/d" $catalog

echo "dylib project successfully removed."
