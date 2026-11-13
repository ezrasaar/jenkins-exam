#!/usr/bin/env bash
set -eu

image=$1
container=$(docker run -d -p 127.0.0.1::8000 "$image")
trap 'docker rm -f "$container" >/dev/null' EXIT
trap 'exit 1' HUP INT TERM

address=$(docker port "$container" 8000/tcp)
url="http://$address/health"

if status=$(timeout 30s curl --silent --fail --retry 30 --retry-all-errors \
    --retry-delay 1 --max-time 2 --output /dev/null --write-out '%{http_code}' "$url") &&
    [ "$status" = "200" ]; then
    echo "GET /health returned 200 for $image"
else
    echo "Health check failed for $image"
    docker logs "$container"
    exit 1
fi
