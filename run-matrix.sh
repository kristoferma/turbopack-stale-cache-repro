#!/bin/bash
# For each Next version / GC setting: cold build without the loader, the loader added over that cache, then cold with it.
set -u
run() { # volume label env...
    local vol=$1 label=$2 clean=$3
    shift 3
    docker run --rm --memory=7g -e REACT_COMPILER=1 "$@" -v "$vol:/work" node:24-bookworm sh /work/measure.sh "$label" $clean
}
for round in 1 2; do
    run tp-repro "r$round-16.3.6-off-cold" clean -e LOADER=off
    run tp-repro "r$round-16.3.6-on-stale" "" -e LOADER=on
    run tp-repro "r$round-16.3.6-on-cold" clean -e LOADER=on
    run tp-repro-canary "r$round-canary-off-cold" clean -e LOADER=off
    run tp-repro-canary "r$round-canary-on-stale" "" -e LOADER=on
    run tp-repro-canary "r$round-canary-on-cold" clean -e LOADER=on
    run tp-repro-canary "r$round-canaryGC-off-cold" clean -e LOADER=off -e GC=1
    run tp-repro-canary "r$round-canaryGC-on-stale" "" -e LOADER=on -e GC=1
    run tp-repro-canary "r$round-canaryGC-on-cold" clean -e LOADER=on -e GC=1
done
