# ==============================================================================
# MODULE: finops-views – FinOps Reporting SQL Views Factory
# ==============================================================================
# Creates 6 BigQuery views that transform raw GCP billing export data into
# KPI-ready tables. Each view is a google_bigquery_table with a SELECT query
# against the auto-created gcp_billing_export_resource_v1_XXXXXX table.
#
# Views created:
#   1. daily_cost               – Day-grain net cost per project/service
#   2. monthly_cost_trend       – Monthly rollup by project/service
#   3. cost_by_project          – Monthly net cost + % of total per project
#   4. top_skus                 – Monthly cost ranked by service/SKU
#   5. discounts_and_commitments – Credits by type (CUD/SUD/free tier/promos)
#   6. cost_anomalies           – Daily z-score spike detection
#
# CRITICAL: Credits are already negative in Billing Export – ALWAYS
#   net = cost + SUM(credits.amount), NEVER cost - credits.
#
# Views created:
#
# Usage example:
#   module "finops_views" {
#     source = "../modules/finops-views"
#     project_id              = module.finops_dataset.project_id
#     dataset_id              = module.finops_dataset.dataset_id
#     billing_export_table_id = "myco-finops.billing_export.gcp_billing_export_resource_v1_XXXXXX"
#   }
# ==============================================================================


# ------------------------------------------------------------------------------
# LOCALS: View definition map (factory input)
# ------------------------------------------------------------------------------
locals {
  billing_export_source = var.billing_export_table_id

  finops_budgets_rows = join(",\n", [
    for t in module.finops_budgets.budget_amounts : format("    STRUCT(\"%s\" AS month, \"%s\" AS project_id, \"%s\" AS currency, %s AS budget_amount)", t.month, t.project_id, t.currency, t.budget_amount)
  ])

  finops_view_definitions = { for k, v in local._view_templates : k => {
    friendly_name = v.friendly_name
    query         = replace(v.query, "{source}", var.billing_export_table_id)
  } }

  _view_templates = {
    daily_cost = {
      friendly_name = "Daily Net Cost"
      query         = <<-EOT
        SELECT
          DATE(usage_start_time)            AS usage_date,
          project.id                        AS project_id,
          project.name                      AS project_name,
          service.description               AS service_description,
          sku.description                   AS sku_description,
          currency                          AS currency,
          SUM(cost)                         AS gross_cost,
          SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS total_credits,
          SUM(cost) + SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS net_cost
        FROM `{source}`
        WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
        GROUP BY 1, 2, 3, 4, 5, 6
      EOT
    }

    monthly_cost_trend = {
      friendly_name = "Monthly Cost Trend"
      query         = <<-EOT
        SELECT
          FORMAT_TIMESTAMP('%Y-%m', usage_start_time) AS month,
          project.id   AS project_id,
          project.name AS project_name,
          service.description                         AS service_description,
          currency                                    AS currency,
          SUM(cost)                                   AS gross_cost,
          SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS total_credits,
          SUM(cost) + SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS net_cost
        FROM `{source}`
        WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
        GROUP BY 1, 2, 3, 4, 5
        ORDER BY 1 DESC
      EOT
    }

    cost_by_project = {
      friendly_name = "Cost by Project"
      query         = <<-EOT
        WITH monthly AS (
          SELECT
            FORMAT_TIMESTAMP('%Y-%m', usage_start_time) AS month,
            project.id                                  AS project_id,
            project.name                                AS project_name,
            currency                                    AS currency,
            SUM(cost) + SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS net_cost
          FROM `{source}`
          WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
          GROUP BY 1, 2, 3, 4
        ),
        totals AS (
          SELECT month, currency, SUM(net_cost) AS total
          FROM monthly
          GROUP BY 1, 2
        )
        SELECT
          m.*,
          ROUND(m.net_cost / NULLIF(t.total, 0) * 100, 2) AS cost_pct
        FROM monthly m
        JOIN totals t ON m.month = t.month AND m.currency = t.currency
      EOT
    }

    top_skus = {
      friendly_name = "Top SKUs"
      query         = <<-EOT
        WITH sku_monthly AS (
          SELECT
            FORMAT_TIMESTAMP('%Y-%m', usage_start_time) AS month,
            service.description                         AS svc,
            sku.description                             AS sku,
            currency                                    AS currency,
            SUM(cost) + SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS net_cost
          FROM `{source}`
          WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
          GROUP BY 1, 2, 3, 4
        )
        SELECT
          *,
          RANK() OVER (PARTITION BY month, currency ORDER BY net_cost DESC) AS rank
        FROM sku_monthly
      EOT
    }

    discounts_and_commitments = {
      friendly_name = "Discounts and Commitments"
      query         = <<-EOT
        SELECT
          FORMAT_TIMESTAMP('%Y-%m', usage_start_time) AS month,
          project.id                                  AS project_id,
          project.name                                AS project_name,
          c.name                                      AS credit_type,
          currency                                    AS currency,
          SUM(c.amount)                               AS credit_amount
        FROM `{source}`, UNNEST(credits) AS c
        WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
        GROUP BY 1, 2, 3, 4, 5
      EOT
    }

    cost_anomalies = {
      friendly_name = "Cost Anomalies"
      query         = <<-EOT
        WITH daily AS (
          SELECT
            DATE(usage_start_time) AS usage_date,
            SUM(cost) + SUM((SELECT SUM(c.amount) FROM UNNEST(credits) AS c)) AS net
          FROM `{source}`
          WHERE _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
          GROUP BY 1
        ),
        stats AS (
          SELECT
            usage_date,
            net,
            AVG(net) OVER (ORDER BY usage_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg7,
            STDDEV(net) OVER (ORDER BY usage_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS std7
          FROM daily
        )
        SELECT
          usage_date,
          ROUND(net, 2)                                               AS net_cost,
          ROUND(avg7, 2)                                              AS trailing_7day_avg,
          ROUND(std7, 2)                                              AS trailing_7day_stddev,
          ROUND((net - avg7) / NULLIF(std7, 0), 2)                    AS z_score,
          CASE WHEN std7 > 0 AND (net - avg7) / std7 > 2.0
               THEN TRUE ELSE FALSE END                               AS is_anomaly
        FROM stats
        WHERE avg7 IS NOT NULL
      EOT
    }

    finops_budgets = {
      friendly_name = "FinOps Budget Targets"
      query         = <<-EOT
        SELECT month, project_id, currency, budget_amount
        FROM UNNEST([
        ${local.finops_budgets_rows}
        ])
      EOT
    }

    monthly_kpi_summary = {
      friendly_name = "Monthly KPI Summary"
      query         = <<-EOT
        WITH daily_cost AS (
          SELECT usage_date, project_id, project_name, net_cost, currency
          FROM `${var.project_id}.${var.dataset_id}.daily_cost`
        ),
        budget_targets AS (
          SELECT month, project_id, currency, budget_amount
          FROM `${var.project_id}.${var.dataset_id}.finops_budgets`
        )
        SELECT
          a.month,
          a.project_id,
          a.project_name,
          a.currency,
          a.monthly_net_cost,
          b.budget_amount,
          ROUND(SAFE_DIVIDE(a.monthly_net_cost, b.budget_amount) * 100, 1) AS burn_rate_pct
        FROM (
          SELECT
            FORMAT_TIMESTAMP('%Y-%m', usage_date) AS month,
            project_id,
            MAX(project_name) AS project_name,
            currency,
            SUM(net_cost) AS monthly_net_cost
          FROM daily_cost
          GROUP BY 1, 2, 4
        ) a
        LEFT JOIN budget_targets b
          ON a.project_id = b.project_id
         AND a.month = b.month
         AND a.currency = b.currency
      EOT
    }
  }
}
