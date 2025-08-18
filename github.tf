# Configure the GitHub Provider

provider "github" {
  owner = "perchnet"
  app_auth {
    id              = local.gh_app_id
    installation_id = local.gh_app_installation_id
    pem_file        = local.gh_app_pem_file
  }
}
data "onepassword_item" "github_infra_app" {
  vault = local.perchnet_vault
  title = "github-infra-app"
}
locals {
  section_data = data.onepassword_item.github_infra_app.section[index(data.onepassword_item.github_infra_app.section[*].label, "data")]

  gh_app_creds = { for field in local.section_data.field : field.label => field.value }

  gh_app_pem_file        = local.gh_app_creds["gh_app_pem_file"]
  gh_app_id              = local.gh_app_creds["gh_app_id"]
  gh_app_installation_id = local.gh_app_creds["gh_app_installation_id"]

}
# This repository
resource "github_repository" "p_repository" {
  name = "p"

  allow_auto_merge            = true
  allow_merge_commit          = true
  allow_rebase_merge          = true
  allow_squash_merge          = true
  allow_update_branch         = true
  archived                    = false
  delete_branch_on_merge      = true
  description                 = "bri's homelab terraform monorepo"
  has_discussions             = false
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = false
  homepage_url                = null
  is_template                 = false
  merge_commit_message        = "PR_BODY"
  merge_commit_title          = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
  topics                      = []
  visibility                  = "public"
  vulnerability_alerts        = true
  web_commit_signoff_required = false

  security_and_analysis {
    secret_scanning {
      status = "disabled"
    }
    secret_scanning_push_protection {
      status = "disabled"
    }
  }
}

resource "github_repository_ruleset" "p_merge_queue" {
  repository  = github_repository.p_repository.name
  enforcement = "active"
  name        = "merge queue"
  rules {
    creation                      = false
    deletion                      = true
    non_fast_forward              = true
    required_linear_history       = true
    required_signatures           = false
    update                        = false
    update_allows_fetch_and_merge = false

    merge_queue {
      check_response_timeout_minutes    = 60
      grouping_strategy                 = "ALLGREEN"
      max_entries_to_build              = 5
      max_entries_to_merge              = 5
      merge_method                      = "SQUASH"
      min_entries_to_merge              = 1
      min_entries_to_merge_wait_minutes = 5
    }

    required_status_checks {
      do_not_enforce_on_create             = false
      strict_required_status_checks_policy = true

      required_check {
        context        = "Terraform"
        integration_id = 15368
      }
    }
  }
  target = "branch"

  bypass_actors {
    actor_id    = 0
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      exclude = []
      include = [
        "~DEFAULT_BRANCH",
      ]
    }
  }

}
