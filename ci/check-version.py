import json
import sys

expected = sys.argv[1]
actual = json.load(sys.stdin).get("version")

if actual != expected:
    sys.exit(f"Version mismatch: expected {expected}, got {actual}")

print(f"Verified application version: {actual}")
