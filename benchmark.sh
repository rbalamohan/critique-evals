#!/usr/bin/env bash
set -euo pipefail

for tc in gt_weekly_success gt_failure_breakdown gt_daily_volume_trend; do
  rm -rf output/$tc && ./run.sh --testcase $tc -n 20 --critic-n 1 --corrupt inner_join
done
