# Recursos da conta, e não do ambiente. Ficam na homologação, aplicada antes da produção,
# como o OIDC provider do GitHub.

# Etiquetas aplicadas pelo Terraform a todos os recursos, ativadas para que o Cost Explorer
# separe o custo por projeto e por ambiente.
resource "aws_ce_cost_allocation_tag" "this" {
  for_each = var.activate_cost_tags ? toset(["Project", "Environment"]) : toset([])

  tag_key = each.value
  status  = "Active"
}

# Orçamento mensal da conta, sem descontar créditos, para avisar por e-mail antes de o
# crédito da AWS acabar.
resource "aws_budgets_budget" "monthly" {
  count = var.monthly_budget_usd > 0 && var.alert_email != "" ? 1 : 0

  name         = "${var.project}-mensal"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_types {
    include_credit = false
    include_refund = false
  }

  dynamic "notification" {
    for_each = [25, 50, 80]
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.alert_email]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
