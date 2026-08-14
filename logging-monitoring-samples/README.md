# logging-monitoring-samples

Batteries-included **sample** log-based metrics and monitoring dashboards for a
project. This module is the worked reference for the `alerting` and
`log-retention` modules: it produces the metrics those alerts fire on and the
dashboards that visualize them. Its `examples/basic/` wires all three modules
together into a complete logging-and-monitoring picture.

## What this module does

- Creates **log-based metrics** (`google_logging_metric`) from
  `var.logging_metrics`. Defaults to two sample security metrics
  (`denied-firewall-hits`, `iam-policy-changes`); pass `{}` to create none.
- Creates **monitoring dashboards** (`google_monitoring_dashboard`) from every
  `*.json` file in this module's `dashboards/` directory. Set
  `create_dashboards = false` to skip them.

Because this is a samples module, it ships opinionated defaults that create
resources with no configuration. Override `logging_metrics` or add/remove JSON
files in `dashboards/` to adapt it.

## Extending

- **Add a metric:** add an entry to `logging_metrics`.
- **Add a dashboard:** drop a new `*.json` file in `dashboards/`. The filename
  becomes the resource key.
- **Alert on a metric:** feed `metric_types` output into the `alerting` module's
  `alert_policies` (`condition_threshold.filter`).

## Usage

See `examples/basic/` for the full stack (metrics + dashboards + alerts +
retention). Minimal shape:

```hcl
module "samples" {
  source = "../logging-monitoring-samples"

  project_id = "my-project"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where sample metrics and dashboards are created. | `string` | n/a | yes |
| logging_metrics | Map of log-based metrics to create, keyed by metric name. | `map(object)` | sample metrics | no |
| create_dashboards | Whether to create the bundled sample dashboards. | `bool` | `true` | no |

## Outputs

| Name | Description |
|---|---|
| metric_ids | Map of metric name to log-based metric resource ID. |
| metric_types | Map of metric name to fully qualified metric type. |
| dashboard_ids | Map of dashboard file name to dashboard resource ID. |
