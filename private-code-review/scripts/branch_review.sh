#!/usr/bin/env bash
set -euo pipefail

# When output is piped (e.g. through `head`), some tools emit noisy "Broken pipe" messages on stderr.
# Filter those messages out while keeping other stderr output intact.
if [[ -z "${NO_BROKEN_PIPE_FILTER:-}" ]]; then
  exec 2> >(grep -v -E 'Broken pipe|write error' >&2)
fi

base_ref="${1:-}"
review_mode="${BRANCH_REVIEW_MODE:-lean}" # lean|full

if ! command -v git >/dev/null 2>&1; then
  echo "git not found in PATH" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

if [[ -z "${base_ref}" ]]; then
  if git show-ref --verify --quiet refs/heads/master; then
    base_ref="master"
  elif git show-ref --verify --quiet refs/heads/main; then
    base_ref="main"
  else
    base_ref="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@' || true)"
    if [[ -z "${base_ref}" ]]; then
      base_ref="HEAD"
    fi
  fi
fi

current_branch="$(git branch --show-current || true)"
current_branch="${current_branch:-DETACHED_HEAD}"
head_sha="$(git rev-parse --short HEAD)"

if ! git rev-parse --verify --quiet "${base_ref}" >/dev/null; then
  echo "Base ref '${base_ref}' not found locally." >&2
  echo "Try: git branch -a" >&2
  exit 2
fi

merge_base="$(git merge-base "${base_ref}" HEAD)"
merge_base_short="$(git rev-parse --short "${merge_base}")"
ahead_count="$(git rev-list --count "${base_ref}..HEAD")"
changed_files="$(git diff --name-only "${base_ref}...HEAD" || true)"
changed_count="$(echo "${changed_files}" | sed '/^$/d' | wc -l | tr -d ' ')"

echo "Branch review summary"
echo "==============================="
echo "Branch      : ${current_branch}"
echo "HEAD        : ${head_sha}"
echo "Base        : ${base_ref}"
echo "Merge-base  : ${merge_base_short}"
echo "Ahead       : ${ahead_count} commits"
echo "Files changed: ${changed_count}"
echo "Mode        : ${review_mode}"
echo

echo "Commits (${base_ref}..HEAD)"
echo "---------------------------"
git log --oneline --no-decorate --max-count 30 "${base_ref}..HEAD" || true
echo

echo "Diffstat (${base_ref}...HEAD)"
echo "-----------------------------"
git diff --stat "${base_ref}...HEAD" || true
echo

if [[ "${review_mode}" == "full" ]]; then
  echo "Changed files (${base_ref}...HEAD)"
  echo "----------------------------------"
  git diff --name-status "${base_ref}...HEAD" || true
  echo
else
  echo "Changed files preview (${base_ref}...HEAD, first 40)"
  echo "-----------------------------------------------------"
  git diff --name-status "${base_ref}...HEAD" | head -n 40 || true
  echo
fi

echo "Touched top-level directories"
echo "-----------------------------"
echo "${changed_files}" | sed '/^$/d' | cut -d/ -f1 | sort | uniq -c | sort -nr || true
echo

echo "Guardrail touch check"
echo "---------------------"
guardrails_csv="${GUARDRAIL_FILES:-}"
guardrails=()
if [[ -n "${guardrails_csv}" ]]; then
  IFS=',' read -r -a guardrails <<< "${guardrails_csv}"
fi
if [[ "${#guardrails[@]}" -eq 0 ]]; then
  echo "(none configured; set GUARDRAIL_FILES=\"path1,path2\")"
else
  for raw_path in "${guardrails[@]}"; do
    path="$(echo "${raw_path}" | sed 's/^ *//;s/ *$//')"
    if [[ -n "${path}" ]] && echo "${changed_files}" | grep -qx "${path}"; then
      echo "WARN: touched guardrail file: ${path}"
    fi
  done
fi
echo

echo "Heuristic code-quality flags (added lines)"
echo "-----------------------------------------"
diff_added="$(git diff -U0 "${base_ref}...HEAD" || true)"

echo "Console.WriteLine additions:"
echo "${diff_added}" | grep -nE '^\+.*Console\.WriteLine' || echo "(none)"
echo

echo "NullLogger additions:"
echo "${diff_added}" | grep -nE '^\+.*NullLogger' || echo "(none)"
echo

echo "Guard.Against.Null usage additions:"
echo "${diff_added}" | grep -nE '^\+.*Guard\.Against\.Null' || echo "(none)"
echo

echo "Test project touch"
echo "------------------"
if echo "${changed_files}" | grep -qE '(\.Tests/|\.Tests\.csproj$)'; then
  echo "Tests changed: yes"
else
  echo "Tests changed: no"
fi
