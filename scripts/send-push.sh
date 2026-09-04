#!/usr/bin/env bash
#
# Send a test push to one device via the Firebase Cloud Messaging HTTP v1 API,
# without needing the PecoNote backend.
#
# Prerequisites (pick ONE auth method):
#   A) gcloud CLI, logged in with an account that can access the Firebase
#      project:  gcloud auth login
#   B) A Firebase service-account key JSON (Firebase console -> Project settings
#      -> Service accounts -> Generate new private key). Set SERVICE_ACCOUNT to
#      its path. Requires python3 with `google-auth` installed
#      (pip install google-auth).
#
# Usage:
#   ./scripts/send-push.sh <FCM_DEVICE_TOKEN> [flavour]
#
# flavour:
#   notify   (default) visible notification + data, routes to /inbox on tap
#   data     data-only message (no tray notification; app handles it)
#   silent   background data payload, content-available for iOS
#
# The device token is printed to the debug console on every debug launch
# ("FCM device token: ...").

set -euo pipefail

PROJECT_ID="peconote-7b134"
TOKEN="${1:?Pass the FCM device token as the first argument}"
FLAVOUR="${2:-notify}"

# --- obtain an OAuth2 access token -------------------------------------------
if [[ -n "${SERVICE_ACCOUNT:-}" ]]; then
  ACCESS_TOKEN="$(python3 - "$SERVICE_ACCOUNT" <<'PY'
import sys
from google.oauth2 import service_account
from google.auth.transport.requests import Request

creds = service_account.Credentials.from_service_account_file(
    sys.argv[1],
    scopes=["https://www.googleapis.com/auth/firebase.messaging"],
)
creds.refresh(Request())
print(creds.token)
PY
)"
else
  ACCESS_TOKEN="$(gcloud auth print-access-token)"
fi

# --- build the message ------------------------------------------------------
case "$FLAVOUR" in
  notify)
    MESSAGE=$(cat <<JSON
{
  "message": {
    "token": "${TOKEN}",
    "notification": {
      "title": "Monobank sync stopped",
      "body": "Reconnect to resume importing transactions."
    },
    "data": {
      "screen": "inbox",
      "path": "/inbox",
      "type": "sync_error"
    },
    "android": { "priority": "high" },
    "apns": {
      "headers": { "apns-priority": "10" },
      "payload": { "aps": { "sound": "default" } }
    }
  }
}
JSON
)
    ;;
  data)
    MESSAGE=$(cat <<JSON
{
  "message": {
    "token": "${TOKEN}",
    "data": {
      "screen": "inbox",
      "path": "/inbox",
      "type": "sync_error",
      "title": "31 payments without a category",
      "body": "Tap to review groups."
    },
    "android": { "priority": "high" }
  }
}
JSON
)
    ;;
  silent)
    MESSAGE=$(cat <<JSON
{
  "message": {
    "token": "${TOKEN}",
    "data": { "type": "refresh" },
    "android": { "priority": "normal" },
    "apns": {
      "headers": { "apns-priority": "5", "apns-push-type": "background" },
      "payload": { "aps": { "content-available": 1 } }
    }
  }
}
JSON
)
    ;;
  *)
    echo "Unknown flavour: $FLAVOUR" >&2
    exit 1
    ;;
esac

# --- send -----------------------------------------------------------------
curl -sS -X POST \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${MESSAGE}"
echo
