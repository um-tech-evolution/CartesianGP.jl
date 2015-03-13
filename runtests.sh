#! /usr/bin/env bash

# Get the directory where the script is located. Should be the
# repository root directoy.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo "./runtests.sh [{nightlies,releases}]"
}

if [ "$#" -eq 1 ]; then
    if [ "$1" == "nightlies" ] || [ "$1" == "releases" ]; then
	vagrant ssh $1 -c '/vagrant/runtests.sh'
	exit 0
    else
	usage
	exit 1
    fi
fi

# Run the tests based on the code in the working directory, not just
# what has been committed.
cd "$DIR/test" && julia -e 'include("../src/CGP.jl"); include("runtests.jl");'
