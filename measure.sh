#!/bin/sh
# Runs inside the container: one `next build`, then the cgroup's peak memory, build time and cache size.
set -u
cd /work
if [ "${2:-}" = clean ]; then rm -rf .next; fi
START=$(date +%s)
npx next build > "/work/build-$1.log" 2>&1
STATUS=$?
END=$(date +%s)
PEAK=$(cat /sys/fs/cgroup/memory.peak)
CACHE=$(du -sm .next/cache/turbopack 2>/dev/null | cut -f1)
COMPILED=$(grep -o 'Compiled successfully in [0-9.]*m\?s' "/work/build-$1.log" | head -1)
WRITE=$(grep -o 'Finished writing to filesystem cache in [0-9.]*m\?i\?n\?s\?' "/work/build-$1.log" | head -1)
echo "$1: exit=$STATUS wall=$((END - START))s peak=$(awk "BEGIN{printf \"%.2f\", $PEAK/1073741824}")GiB cache=${CACHE:-0}MB | $COMPILED | $WRITE"
