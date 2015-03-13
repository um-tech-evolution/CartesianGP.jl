#! /usr/bin/env sh

julia -e 'Pkg.clone(pwd()); Pkg.test("CGP")'
