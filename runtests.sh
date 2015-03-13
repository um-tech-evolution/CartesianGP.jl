#! /usr/bin/env bash

# Get the directory where the script is located. Should be the
# repository root directoy.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo "./runtests.sh [{nightlies,releases}]"
}

runtests() {
    echo "Environment: $1"
    vagrant ssh "$1" -c '/vagrant/runtests.sh'
}

if [ "$#" -eq 1 ]; then
    if [ "$1" == "nightlies" ] || [ "$1" == "releases" ]; then
	runtests $1
	exit 0
    elif [ "$1" == "all" ]; then
	runtests "nightlies"
	runtests "releases"
	exit 0
    else
	usage
	exit 1
    fi
fi

# Run the tests based on the code in the working directory, not just
# what has been committed.
cd "$DIR/test" && julia -e 'include("../src/CGP.jl"); include("runtests.jl");'
