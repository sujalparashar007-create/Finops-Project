import json
import os
import smtplib
import urllib.request
import urllib.error
from email.mime.text import MIMEText

# ==============================================================================
# LOCAL TEST HARNESS for budget alert processor
# ==============================================================================
# Usage: Set environment variables before running this script.
#   PowerShell:
#     $env:GMAIL_USER = "your-email@gmail.com"
#     $env:GMAIL_APP_PASSWORD = "your-app-password"
#     $env:TEAMS_WEBHOOK_URL = "https://..."
#     python test_local.py
#
# NEVER commit real credentials to this file.
# ==============================================================================

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

print()
print("=== TESTING GMAIL ===")
try:
    msg = MIMEText("Test email from FinOps function")
    msg["Subject"] = "FinOps Local Test"
    msg["From"] = os.environ["GMAIL_USER"]
    msg["To"] = os.environ["GMAIL_USER"]
    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
        server.login(os.environ["GMAIL_USER"], os.environ["GMAIL_APP_PASSWORD"])
        server.send_message(msg)
    print("SUCCESS: Email sent")
except Exception as e:
    print(f"ERROR: {e}")

