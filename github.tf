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
# resource "github_repository" "p_repository" {
#   name = "p"
# 
#   allow_auto_merge            = false
#   allow_merge_commit          = true
#   allow_rebase_merge          = true
#   allow_squash_merge          = true
#   allow_update_branch         = false
#   archived                    = false
#   delete_branch_on_merge      = false
#   description                 = null
#   has_discussions             = false
#   has_downloads               = true
#   has_issues                  = true
#   has_projects                = true
#   has_wiki                    = false
#   homepage_url                = null
#   is_template                 = false
#   merge_commit_message        = "PR_TITLE"
#   merge_commit_title          = "MERGE_MESSAGE"
#   squash_merge_commit_message = "COMMIT_MESSAGES"
#   squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
#   topics                      = []
#   visibility                  = "public"
#   vulnerability_alerts        = true
#   web_commit_signoff_required = false
# 
#    security_and_analysis {
#      secret_scanning {
#        status = "disabled"
#      }
#      secret_scanning_push_protection {
#        status = "disabled"
#      }
#    }
# }