# Secrets loaded from 1Password at shell startup
# Requires: op CLI authenticated (biometric via 1Password desktop app)
# Uses personal account (my.1password.com) Private vault
#
# To add a new secret:
#   1. Store it in 1Password (Private vault, personal account)
#   2. Add an op read line below
#   3. Use: op read "op://Private/Item Name/field"

# Only load if op is available and authenticated
if command -v op &>/dev/null; then
  export SENTRY_USER_AUTH_TOKEN=$(op read "op://Private/Sentry User Auth Token/credential" --account my.1password.com 2>/dev/null)
  export ROLLBAR_KEY=$(op read "op://Private/Rollbar Key/credential" --account my.1password.com 2>/dev/null)
fi
