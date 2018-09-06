#!/bin/sh

pushd "`dirname "$0"`" > /dev/null
scriptpath="`pwd`"
popd > /dev/null

. "$scriptpath/include.sh/build-dep.sh"

url="https://github.com/dsanghan/libetpan.git"
rev=3a03d1334824af1d0bc204d49dc2796ff632f631
name="libetpan-osx"
xcode_target="static libetpan"
xcode_project="libetpan.xcodeproj"
library="libetpan.a"
embedded_deps=""

build_git_osx
