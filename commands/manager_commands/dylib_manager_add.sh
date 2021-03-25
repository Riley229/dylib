#!bin/bash

. $catalog

# verifies input isn't empty and provides error message if it is
function check-input() {
    inputValue=$1
    inputName=$2

    if [ "$1" == "" ]; then
	echo  "You must enter $inputName"
	echo -e "\tTask aborted"
	exit 1
    fi
}

# initialize dialog
echo "Beginning new project dialog..."
echo ""

# get project name
read -p "Enter new dylib project name: " name
echo ""
check-input $name "dylib project name"

# get project classification
echo "Dylib project classifications:"
echo -e "\t1. library"
echo -e "\t2. project"
read -p "Enter dylib project classification (number): " classification
echo ""
check-input $classification "dylib project classification"

# check classification is a valid value (1 or 2)
if ! [[ "$classification" =~ ^[0-9]+$ ]] || [ "$classification" -lt 1 ] || [ "$classification" -gt 2 ]; then
    echo "You must enter a dylib project classification number between 1 and 2"
    echo -e "\tTask aborted"
    exit 1
fi

# get classificationName from classification number value
[[ $classification = 1 ]] && classificationName="library" || classificationName="project"

# if dylib project is a library, get library version
if [[ $classification = 1 ]]; then
       read -p "Enter the current dylib library version: " libraryVersion
       echo ""
       check-input $libraryVersion "current dylib library version"
fi

# get dylib library url (or confirm assumed url is correct)
repository="https://github.com/TheCoderMerlin/$name"
echo "calculated project repository url: $repository"
read -p "Enter the project repository url (alternatively enter 'yes' if calculated url is correct): " repositoryResponse
echo ""

if ! [[ "$repositoryResponse" == "yes" ]]; then
    repository=$repositoryResponse
    check-input $repository "project repository url"
fi

# get list of dylib dependencies
echo "Merlin dynamic libraries:"
for libraryId in "${!libraries[@]}"; do
    visibleId=$((libraryId+1))
    echo -e "\t$visibleId. ${libraries[$libraryId]}"
done
read -p "Enter comma delimited list of dependencies (ex: 1,2): " dependenciesRaw
echo ""

# translate raw dependencies to readable dependencies
dependencies="("
for libraryId in $(echo $dependenciesRaw | sed "s/,/ /g"); do
    dependencies+=" \"${libraries[libraryId-1]}\""
done
dependencies+=" )"

#review everything
echo "Generating dylib project report..."
echo -e "\tname: $name"
echo -e "\tclassification: $classificationName"
if [ $classification == "1" ]; then
    echo -e "\tlibraryVersion: $libraryVersion"
fi
echo -e "\trepository: $repository"
echo -e "\tdependencies: ${dependencies}"
read -p "Does dylib project appear correct (y/n): " confirmation
echo ""

# cancel if information is wrong
if [[ "$confirmation" = "n" ]]; then
    echo "Task aborted"
    exit 1
elif [[ "$confirmation" != "y" ]]; then
    echo "You must enter either 'y' or 'n'"
    echo -e "\tTask aborted"
    exit 1
fi

# add project to dylib catalog
echo "Adding new dylib project $name to dylib catalog..."

# add to either libraries or projects depending on classification.
if [ $classification == "1" ]; then
    libraries+=( "$name" )
else
    projects+=( "$name" )
fi

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

# append projects data to end of file
echo "" >> $catalog
if [ $classification == "1" ]; then
    echo "${name}_libraryVersion=\"${libraryVersion}\"" >> $catalog
fi
echo "${name}_repository=\"${repository}\"" >> $catalog
echo "${name}_dependencies=${dependencies}" >> $catalog

echo "dylib project successfully added. To deploy project, use the command 'dylib manager deploy'"
