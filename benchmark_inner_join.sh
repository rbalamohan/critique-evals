#!/usr/bin/env bash
set -euo pipefail

rm -rf output/gt_worker_leaderboard
./run.sh --testcase gt_worker_leaderboard -n 20 --critic-n 1 --corrupt inner_join
