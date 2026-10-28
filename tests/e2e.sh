#!/usr/bin/env bash
# End-to-end test: a vote cast on the vote page must reach Postgres through Redis and the worker,
# changing that vote must update it (not add a second one), and the result page must load.
# Expects the stack to be running (see docker-compose.test.yml).
set -euo pipefail

VOTE_URL="${VOTE_URL:-http://localhost:8080}"
RESULT_URL="${RESULT_URL:-http://localhost:8081}"
COMPOSE="docker compose -f docker-compose.yml -f docker-compose.test.yml"
COOKIES="$(mktemp)"
trap 'rm -f "$COOKIES"' EXIT

fail() {
  echo "FAIL: $1"
  $COMPOSE logs --tail 30 vote worker result || true
  exit 1
}

# prints the saved votes as "a:1" style lines, sorted
db_votes() {
  $COMPOSE exec -T db psql -U postgres -tAc \
    "SELECT vote || ':' || count(*) FROM votes GROUP BY vote ORDER BY vote" 2>/dev/null || true
}

# waits up to 30s for the saved votes to match what we expect
wait_for_votes() {
  local expected="$1"
  for _ in $(seq 1 30); do
    [ "$(db_votes)" = "$expected" ] && return 0
    sleep 1
  done
  fail "expected votes '$expected' in Postgres, got '$(db_votes)'"
}

echo "1. vote page loads"
curl -fsS -o /dev/null "$VOTE_URL" || fail "vote page did not load"

echo "2. a vote for Cats is saved"
curl -fsS -o /dev/null -c "$COOKIES" -X POST -d "vote=a" "$VOTE_URL" || fail "vote was not accepted"
wait_for_votes "a:1"

echo "3. the same voter changing to Dogs updates the vote"
curl -fsS -o /dev/null -b "$COOKIES" -X POST -d "vote=b" "$VOTE_URL" || fail "vote change was not accepted"
wait_for_votes "b:1"

echo "4. result page loads"
curl -fsS "$RESULT_URL" | grep -q "Cats vs Dogs" || fail "result page did not load"

echo "PASS: all end-to-end checks passed"
