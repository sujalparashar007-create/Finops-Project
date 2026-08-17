# ==============================================================================
# FINOPS-PROJECT: All Errors Encountered During Deployment & Their Fixes
# ==============================================================================

# ==============================================================================
# SECTION 1: PROJECT BOOTSTRAP (project/ module)
# ==============================================================================

# --- ERROR 1: Cloud Resource Manager API not enabled ---
# Symptom: Error 403 when reading project via data "google_project"
# Fix: Added to project module activate_apis: cloudresourcemanager, iam, serviceusage, cloudbilling

# --- ERROR 2: IAM API not enabled ---
# Fix: Included in project module default activate_apis

# --- ERROR 3: Service Usage API not enabled ---
# Root: serviceusage.googleapis.com is the gateway API - must be enabled first
# Fix: Included in project module default activate_apis

# --- ERROR 4: Cloud Billing API not enabled ---
# Fix: Included in project module default activate_apis

# --- ERROR 5: Compute API stuck deactivating ---
# Symptom: "Error code 9: The service is currently being deactivated"
# Fix: Removed compute.googleapis.com from activate_apis; not needed for FinOps

# --- ERROR 6: App Engine / Compute default SAs don not exist ---
# Symptom: Error 404 "Unknown service account" for appspot and compute SAs
# Fix: Moved act-as grants out of project module; only self act-as at bootstrap

# ==============================================================================
# SECTION 2: MODULE REFERENCE ERRORS (6-finops/ root module)
# ==============================================================================

# --- ERROR 7: Module source "finops-org-policy" not found ---
# Symptom: "Unreadable module directory: GetFileAttributesEx ..\finops-org-policy"
# Fix: Changed source = "../hierarchical-policy" in main.tf

# --- ERROR 8: Missing required argument "scope" ---
# Fix: Added scope = "organization" to hierarchical_policy module block

# --- ERROR 9: Org-level firewall policy "projects/null" ---
# Symptom: "Error creating FirewallPolicy: The resource projects/null was not found"
# Root: tf-executor SA has no org-level permissions to create firewall policies
# Fix: Removed hierarchical_policy module from 6-finops; deploy separately with admin creds

# ==============================================================================
# SECTION 3: DUPLICATE IAM GRANTS (project module vs 6-finops)
# ==============================================================================

# --- ERROR 10: IAM permission denied (403 forbidden) ---
# Symptom: "Policy update access denied" for project-level IAM grants
# Root: 6-finops runs as tf-executor SA; cant grant itself roles it already has
# Fix: Removed foundation_iam local from 6-finops/main.tf. Set iam = {} in finops_foundation.

# --- ERROR 11: Duplicate billing admin grant ---
# Fix: Removed inline google_billing_account_iam_member from 6-finops

# --- ERROR 12: Duplicate SA act-as grants ---
# Fix: Moved all act-as grants to project module; removed from 6-finops

# ==============================================================================
# SECTION 4: CROSS-PROJECT BIGQUERY ACCESS
# ==============================================================================

# --- ERROR 13: Billing export table access denied ---
# Symptom: "Access Denied: Table project-6f3b3c54-b345-4d07-be1:billing_export..."
# Root: Billing export in old project; tf-executor@new-project has no BigQuery access there
# Fix: Granted roles/bigquery.dataViewer on old project to tf-executor@finops-foundation-test

# --- ERROR 14: Billing export table not found in new project ---
# Symptom: "Not found: Table finops-foundation-test:billing_export.daily_cost"
# Fix: Used old project export table (billing_export_table_id in terraform.tfvars)

# ==============================================================================
# SECTION 5: CLOUD FUNCTION DEPLOYMENT ERRORS (MOST ERRORS HERE)
# ==============================================================================

# --- ERROR 15: Cloud Build SA missing permission (persistent) ---
# Symptom: "Build failed: Could not build the function due to missing permission
#          on the build service account"
# Root: Default Cloud Build SA (633799098509@cloudbuild.gserviceaccount.com) is
#       a Google-managed agent that behaves differently; even roles/owner fails
# Fix: Set build_config.service_account = tf-executor as build SA in finops-function/main.tf

# --- ERROR 16: Cloud Build SA roles cascade ---
# Symptom: Multiple permission errors during build steps (logging, artifact registry, run)
# Root: tf-executor as build SA needs same roles the default Cloud Build SA would need
# Fix: Granted to tf-executor: roles/logging.logWriter, roles/artifactregistry.writer,
#       roles/artifactregistry.reader, roles/run.admin, roles/eventarc.eventReceiver

# --- ERROR 17: Cloud Build SA not in service account list ---
# Symptom: NOT_FOUND for 633799098509@cloudbuild.gserviceaccount.com
# Root: Cloud Build SA is a service AGENT in a special pool (gcp-sa-cloudbuild)
# Fix: gcloud beta services identity create --service=cloudbuild.googleapis.com

# --- ERROR 18: Eventarc trigger / Cloud Run service not found (cascade) ---
# Symptom: "Cloud Run service ... was not found" + "Eventarc trigger ... was not found"
# Root: Function build failed (ERROR 15), so Cloud Run service/Eventarc trigger never created
# Fix: Solved by fixing ERROR 15

# --- ERROR 19: Cloud Run IAM race condition ---
# Symptom: "Resource ... of kind SERVICE does not exist" for pubsub_invoker IAM
# Root: google_cloud_run_service_iam_member had no depends_on the function resource
# Fix: Added depends_on = [google_cloudfunctions2_function.alert_processor] + count condition

# ==============================================================================
# SECTION 6: RESOURCE CONFLICTS (PARTIAL APPLY LEFTOVERS)
# ==============================================================================

# --- ERROR 20: Pub/Sub topic already exists (409) ---
# Fix: terraform import into state

# --- ERROR 21: BigQuery dataset already exists (409) ---
# Fix: terraform import into state

# --- ERROR 22: GCS bucket already exists (409) ---
# Fix: terraform import into state

# --- ERROR 23: Secrets already exist (409) ---
# Fix: terraform import both secrets into state

# --- ERROR 24: BigQuery views partially created ---
# Symptom: monthly_kpi_summary not found; depends on daily_cost which had propagation delay
# Fix: Imported all 7 existing views; monthly_kpi_summary created on re-apply

# --- ERROR 25: Duplicate billing budgets ---
# Symptom: 4 budgets found, only 2 in Terraform state
# Fix: Deleted orphaned budgets manually

# --- ERROR 26: Cloud Function already exists (409) ---
# Fix: Deleted function first, then re-apply (function tainted and replaced)

# ==============================================================================
# SECTION 7: SECURITY FINDINGS (post-deployment review)
# ==============================================================================

# --- ERROR 27: roles/run.invoker granted to allUsers (HIGH) ---
# Symptom: Cloud Run service open to anonymous internet
# Root: google_cloud_run_service_iam_member.pubsub_invoker used allUsers
# Fix: Changed to Eventarc service agent:
#   member = "serviceAccount:service-{NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"
#   Added data "google_project" to look up project number for constructing the SA email

# --- ERROR 28: Function reuses tf-executor SA as runtime identity (MEDIUM) ---
# Symptom: Cloud Function runs as Terraform deployment SA (over-privileged)
# Root: locals.service_account_email had fallback to tf-executor
# Fix: Added create_service_account variable (CFF pattern). Module creates a dedicated SA
#   fb-alert-processor-sa with roles/logging.logWriter + secretmanager.secretAccessor

# ==============================================================================
# SECTION 8: CONFIGURATION / MISC ERRORS
# ==============================================================================

# --- ERROR 29: SA account_id too long ---
# Symptom: "account_id 'finops-budget-alert-processor-sa' must be 6-30 chars" (36 chars)
# Fix: Shortened with replace: "finops-budget" -> "fb" => "fb-alert-processor-sa" (24 chars)

# --- ERROR 30: Terraform state migration to GCS fails ---
# Symptom: "bucket doesn not exist" during terraform init -migrate-state
# Fix: Create bucket first: gcloud storage buckets create gs://finops-foundation-test-tfstate

# --- ERROR 31: Stale 6-finops/6-finops directory ---
# Fix: Deleted nested 6-finops/6-finops/ entirely. Single root: 6-finops/

# --- ERROR 32: Stale files (migrate-state.ps1, nul, function-source.zip, tfvars.example)
# Fix: Deleted all unnecessary files from 6-finops/

# ==============================================================================
# KEY TAKEAWAYS FOR FUTURE DEPLOYMENTS
# ==============================================================================
#
# 1. ALWAYS run project module FIRST to bootstrap project, SA, APIs, and IAM.
#    Never grant IAM from 6-finops (runs as tf-executor which cant grant itself).
#
# 2. Cloud Build default SA on new GCP projects is unreliable for Cloud Functions v2.
#    Use build_config.service_account = tf-executor with extra roles.
#
# 3. On partial apply failures, IMPORT resources instead of deleting state.
#
# 4. Billing export lives in OLD project. Grant cross-project BigQuery access.
#
# 5. Org-level resources (firewall) cant be created by project SA. Deploy separately.
#
# 6. GCP SA account_id max 30 chars. Use short names.
#    Deployed dedicated SA: fb-alert-processor-sa
