
data "local_file" "main_dashboard" {
  filename = "${path.module}/main_dashboard.json"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Main"

  dashboard_body = data.local_file.main_dashboard.content
}

