# Email Notification Channel Verification Guide

## Current Status
- **Channel Name:** ops-email
- **Type:** email
- **Recipient:** sujalparashar007@gmail.com
- **Project:** tf-logs-771071
- **Channel ID:** projects/tf-logs-771071/notificationChannels/5868926195811950805
- **Status:** ⚠️ UNVERIFIED
- **Created:** 2026-08-13T21:54:49.643319043Z

## Problem Summary
The `ops-email` notification channel was successfully created in the tf-logs-771071 GCP project, but it remains **unverified**. Email notification channels in GCP must be verified by the recipient before they can deliver alert notifications.

**Impact:** Alerts configured to use this channel will NOT be sent to the email address until verification is complete.

## Why Verification is Required
GCP requires email verification to:
- Prevent notifications from being sent to unauthorized email addresses
- Ensure the email owner has intentionally opted in to receive notifications
- Comply with anti-spam requirements

## How to Verify

### Option 1: Verify via Email Link (Fastest)
1. Log in to your email inbox at: **sujalparashar007@gmail.com**
2. Look for an email from **Google Cloud Monitoring** (or similar sender)
3. The email subject should contain something like "Verify email" or "Email Notification Verification"
4. Click the verification link in the email
5. The channel will be marked as **VERIFIED** immediately
6. Verification is complete—no further action needed

**Email not received?** Proceed to Option 2.

### Option 2: Resend Verification Email from Cloud Console
1. Open Google Cloud Console: https://console.cloud.google.com
2. Select project **tf-logs-771071** from the project dropdown
3. Navigate to **Monitoring** → **Alerting** → **Notification channels**
4. Find and click the **ops-email** channel
5. In the channel details page, look for a **"Resend verification"** or **"Verify now"** button
6. Click it to resend the verification email
7. Check your email inbox (and spam folder) for the verification email from GCP
8. Click the verification link in the email

### Option 3: Programmatic Verification (For Automation)
Unfortunately, GCP does not currently provide a fully programmatic API to verify email channels without user interaction. However, you can:

**Check verification status:**
```bash
gcloud beta monitoring channels describe \
  projects/tf-logs-771071/notificationChannels/5868926195811950805 \
  --project=tf-logs-771071 \
  --format=json
```

Look for the `"verificationStatus"` field. When verified, it will show:
```json
"verificationStatus": "VERIFIED"
```

When unverified, the field will be absent or show:
```json
"verificationStatus": "UNVERIFIED"
```

## Verification Confirmation
After completing verification, run the command above to confirm the channel is now **VERIFIED**.

Expected output:
```json
{
  "displayName": "ops-email",
  "enabled": true,
  "labels": {
    "email_address": "sujalparashar007@gmail.com"
  },
  "name": "projects/tf-logs-771071/notificationChannels/5868926195811950805",
  "type": "email",
  "verificationStatus": "VERIFIED"
}
```

## Testing Alert Delivery (After Verification)
Once verified, you can test alert delivery by:
1. Triggering a test alert through the monitoring dashboard
2. Or temporarily modifying an existing alert policy to use a metric with current data
3. Verify that you receive the notification email within a few minutes

## Terraform Notes
- The notification channel is defined in: `logging-monitoring-samples/examples/basic/main.tf`
- It uses the `alerting` module which creates the channel via `google_monitoring_notification_channel` resource
- Terraform cannot programmatically verify email channels; verification must be completed manually via email or console
- Re-running `terraform apply` will NOT verify the channel (it only manages the channel's existence and properties)

## Troubleshooting

### Email Not Received After 5+ Minutes
1. Check your spam/junk folder
2. Use Option 2 to resend from Cloud Console
3. Verify the email address is correct: `sujalparashar007@gmail.com`
4. Check that the project ID is correct: `tf-logs-771071`

### Still Not Receiving Verification Email
- Ensure the email address has proper spam filters configured
- Contact your email provider to check for blocked senders from Google Cloud
- Try adding Google Cloud's sender domains to your safe senders list

### After Verification, Alerts Still Not Received
- Verify the alert policy is enabled
- Check the alert condition thresholds and filters
- Verify the notification channel is assigned to the alert policy
- Check Cloud Monitoring documentation for alert firing conditions

## Related Resources
- [GCP Notification Channels Documentation](https://cloud.google.com/monitoring/api/v3/notifications)
- [GCP Alert Policies Documentation](https://cloud.google.com/monitoring/alerts/docs)
- [GCP Cloud Console - Alerting](https://console.cloud.google.com/monitoring/alerting)

## Next Steps
1. **Immediately:** Check your email for the verification link and click it
2. **Confirm:** Run the verification status command to confirm "VERIFIED" status
3. **Optional:** Generate test data to verify alert delivery is working
4. **Final:** Update terraform-outputs to reflect verified status once complete
