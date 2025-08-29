#!/usr/bin/env bash
set -euxo pipefail

env | grep ANALYTICS_DISABLED || exit 1

wait_for_port 1234
curl -sf "http://127.0.0.1:1234/signup/setup"
