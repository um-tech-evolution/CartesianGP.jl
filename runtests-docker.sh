#!/bin/sh

docker build --build-arg version=releases -t julia:release .
docker build --build-arg version=nightlies -t julia:nightly .

echo "Running tests on release version..."
docker run -v "$PWD":/opt/src julia:release
echo "Running tests on latest version..."
docker run -v "$PWD":/opt/src julia:nightly

