terraform {
  required_providers {
    slack-token = {
      source  = "change-engine/slack-token"
      version = "~> 0.1"
    }
    slack-app = {
      source  = "change-engine/slack-app"
      version = "~> 0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-sample-slack-bolt"
    region = "ap-northeast-1"
    key = "main/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region  = "ap-northeast-1"
}

# S3バケットの定義
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-sample-slack-bolt"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "slack-token_refresh" "config" {
  # This resource _must_ be imported.
  # Generate a new "App Configuration Token" via https://api.slack.com/authentication/config-tokens
  # Copy the "Refresh Token", it should start `xoxe-...`
  # Then run `terraform import slack-token_refresh.config xoxe-...`
}

provider "slack-app" {
  token = slack-token_refresh.config.token
}

resource "slack-app_manifest" "slack-app" {
  manifest = jsonencode({
    display_information = {
      name             = "sample-slack-bolt"
      description      = "特定のメッセージを受け取り、ダッシュボードのスクリーンショットを取得してSlackに投稿します。"
      background_color = "#36C5F0"
    }
    features = {
      bot_user = {
        display_name  = "sample-slack-bolt"
        always_online = false
      }
    }
    oauth_config = {
      scopes = {
        bot = [
          "chat:write",
          "chat:write.public",
          "channels:history",
          "groups:history",
          "im:history",
          "mpim:history",
          "channels:read",
          "groups:read"
        ]
      }
    }
    settings = {
      org_deploy_enabled     = false
      socket_mode_enabled    = false
      token_rotation_enabled = false
    }
  })
}