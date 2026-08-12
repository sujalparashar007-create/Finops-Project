import json
import os
import urllib.request
import urllib.error

# ===================================================================
# LOCAL TEST HARNESS for budget alert processor
# ===================================================================
# Usage: Set TEAMS_WEBHOOK_URL environment variable before running.
#   $env:TEAMS_WEBHOOK_URL = "https://..."
#   python test_local.py
# ===================================================================

print("=== TESTING TEAMS WEBHOOK ===")
payload = {
    "budgetName": "LOCAL TEST",
    "threshold": 50,
    "costAmount": 25000,
    "budgetAmount": 50000,
    "currencyCode": "INR",
    "text": "Budget Alert: LOCAL TEST - 25000/50000 INR (50%)"
}
print(f"Payload: {json.dumps(payload)}")

try:
    req = urllib.request.Request(
        os.environ["TEAMS_WEBHOOK_URL"],
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"}
    )
    resp = urllib.request.urlopen(req)
    body = resp.read().decode()
    print(f"SUCCESS: HTTP {resp.status}")
    print(f"Response body: {body}")
except urllib.error.HTTPError as e:
    body = e.read().decode()
    print(f"HTTP ERROR: {e.code}")
    print(f"Response body: {body}")
except Exception as e:
    print(f"ERROR: {e}")