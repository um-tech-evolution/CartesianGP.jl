# CGP.jl

[![Build Status](https://travis-ci.org/glesica/CGP.jl.svg?branch=master)](https://travis-ci.org/glesica/CGP.jl)

CGP.jl is a library for using
[Cartesian Genetic Programming](http://www.cartesiangp.co.uk/) in
Julia. It is being developed at the University of Montana in Missoula,
MT for use in simulating the evolution of technology, though there is
nothing specific to that application in the library so it is (will be)
perfectly suitable for other applications as well.

## Development

There is a [Vagrant](http://docs.vagrantup.com/) configuration file
(called `Vagrantfile`) in the repository root that will provide a
properly configured development and test-running environment (using
[Virtualbox](https://www.virtualbox.org/) behind the scenes. This is
especially helpful for Mac and Windows users for whom keeping Julia
up-to-date can be a bit of a challenge.

Additionally, this method protects the developer's system Julia
packages, which is ideal for people who are both using and developing
CGP.jl.

Once
[Vagrant is installed](http://docs.vagrantup.com/v2/getting-started/index.html),
bring up the VM with the following command:

```
$ vagrant up
```

Launching the VM will cause the test suite to run. The tests can be
subsequently run in the VM like so:

```
$ vagrant ssh -c $'julia -e \'Pkg.clone("/vagrant", "CGP"); Pkg.test("CGP")\''
```

To shut down the VM:

```
$ vagrant halt
```

To destroy the VM (and free the hard drive space used to store its disk image:

```
$ vagrant destroy
```
