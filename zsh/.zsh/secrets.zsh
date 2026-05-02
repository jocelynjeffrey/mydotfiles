# Secrets lazy-loaded from 1Password on first use
# Requires: op CLI authenticated (biometric via 1Password desktop app)
# Uses personal account (my.1password.com) Private vault
#
# To add a new secret:
#   1. Store it in 1Password (Private vault, personal account)
#   2. Add a function below following the same pattern
#   3. Use: op read "op://Private/Item Name/field"

# Lazy-load helper: fetches from 1Password on first access, caches in env for session
_op_lazy() {
  local var_name=$1 op_ref=$2
  if [[ -z "${(P)var_name}" ]] && command -v op &>/dev/null; then
    export "$var_name"="$(op read "$op_ref" --account my.1password.com 2>/dev/null)"
  fi
  echo "${(P)var_name}"
}

SENTRY_USER_AUTH_TOKEN() { _op_lazy SENTRY_USER_AUTH_TOKEN "op://Private/Sentry User Auth Token/credential"; }
ROLLBAR_KEY() { _op_lazy ROLLBAR_KEY "op://Private/Rollbar Key/credential"; }

# Sourcegraph CLI - lazy-load via wrapper since CLI reads env directly
src() {
  if [[ -z "$SRC_ACCESS_TOKEN" ]] && command -v op &>/dev/null; then
    export SRC_ACCESS_TOKEN="$(op read 'op://Private/Sourcegraph Token (Claude Code CLI)/password' --account my.1password.com 2>/dev/null)"
  fi
  command src "$@"
}

# Jira CLI (jira-cli) - lazy-load via wrapper since CLI reads env directly
jira() {
  if [[ -z "$JIRA_API_TOKEN" ]] && command -v op &>/dev/null; then
    export JIRA_API_TOKEN="$(op read 'op://Private/Jira CLI Personal Token/password' --account my.1password.com 2>/dev/null)"
  fi
  command jira "$@"
}
