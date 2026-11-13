#!/usr/bin/env bash
set -eu

image=$1
container=$(docker run -d -p 127.0.0.1::8000 "$image")
trap 'docker rm -f "$container" >/dev/null' EXIT
trap 'exit 1' HUP INT TERM

address=$(docker port "$container" 8000/tcp)
url="http://$address/health"

if timeout 30s bash -c '
    while true; do
        if status=$(curl --silent --max-time 2 --output /dev/null --write-out "%{http_code}" "$1") && [ "$status" = "200" ]; then
            exit 0
        fi
        sleep 1
    done
' _ "$url"; then
    echo "GET /health returned 200 for $image"
else
    echo "Health check failed for $image"
    docker logs "$container"
    exit 1
fi
