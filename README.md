# Turbopack: a build over a cache from a different pipeline is slower than a cold build

A generated App Router app (100 routes × 20 components). Every component imports from `fake-macro`, and a Babel webpack loader expands it through `turbopack.rules` with a `content` condition. `LOADER=off|on` removes or adds that rule, which changes the compile pipeline between two builds that share `.next/cache`.

## Run (Linux container, so cgroup `memory.peak` measures each build)

```sh
docker volume create tp-repro
docker run --rm -v tp-repro:/work -v "$PWD":/src:ro node:24-bookworm cp -r /src/. /work/
docker run --rm -w /work -e ROUTES=100 -e COMPONENTS=20 -v tp-repro:/work node:24-bookworm node generate.mjs
docker run --rm -w /work -v tp-repro:/work node:24-bookworm npm install --no-audit --no-fund

# 1. cold build without the loader rule
docker run --rm --memory=7g -e REACT_COMPILER=1 -e LOADER=off -v tp-repro:/work node:24-bookworm sh /work/measure.sh off-cold clean
# 2. add the loader rule, build over that cache
docker run --rm --memory=7g -e REACT_COMPILER=1 -e LOADER=on  -v tp-repro:/work node:24-bookworm sh /work/measure.sh on-stale
# 3. same pipeline as 2, but from an empty cache
docker run --rm --memory=7g -e REACT_COMPILER=1 -e LOADER=on  -v tp-repro:/work node:24-bookworm sh /work/measure.sh on-cold clean
```

`measure.sh` prints wall time, cgroup peak memory, Turbopack cache size and the "Compiled successfully in" time. `run-matrix.sh` runs the whole comparison twice for 16.3.6 and a canary (`GC=1` sets `experimental.turbopackGc`); it expects a second volume `tp-repro-canary` with `next@canary` installed.
