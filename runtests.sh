#! /usr/bin/env bash

# Get the directory where the script is located. Should be the
# repository root directoy.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the tests based on the code in the working directory, not just
# what has been committed.
cd "$DIR/test" && julia -e 'include("../src/CGP.jl"); include("runtests.jl");'
