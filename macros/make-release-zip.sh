#!/bin/bash
set -ue
set -x

version=$(awk '/^Version:/ { print $2 }' doc/caw.txt)
git archive --format=zip master -- after autoload doc macros plugin >caw-v${version}.zip
echo "Done!: caw-v${version}.zip"
