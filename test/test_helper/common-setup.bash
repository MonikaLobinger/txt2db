#!/usr/bin/env bash

_common_setup() {
    local subdir=""
    local downdir=""
    local dirdown="/.."
    if [[ -v "1" ]]; then subdir="/$1";
        local res="${subdir//[^\/]}"
        local depth=${#res}
        local i=$depth
        downdir="$(while ((i>0)); do ((i=i-1)); echo -n '../'; done )";
        ((depth=depth+1))
        i=$depth
        dirdown="$(while ((i>0)); do ((i=i-1)); echo -n '/..'; done )";
    fi
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    THIS_TEST_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PROJECT_ROOT="$THIS_TEST_DIR$dirdown"
    PATH="$THIS_TEST_DIR$dirdown$subdir:$PATH"
    # echo ">>>\$1: $1"
    # echo ">>>SUBDIR: $subdir"
    # echo ">>>DEPTH: $depth"
    # echo ">>>DOWNDIR: $downdir"
    # echo ">>>DIRDOWN: $dirdown"
    load "${downdir}test_helper/bats-support/load"
    load "${downdir}test_helper/bats-assert/load"
    # echo ">>>THIS_TEST_DIR: $THIS_TEST_DIR"
    # echo ">>>PROJECT_ROOT: $PROJECT_ROOT"
    # echo ">>>PATH: $PATH"

    # make executables in src/ visible to PATH
    # PATH="$PROJECT_ROOT/src:$PATH"

}
