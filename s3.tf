resource "cloudflare_r2_bucket" "misskey" {
  account_id    = var.cloudflare_account_id
  name          = "misskey"
  location      = "apac"
  storage_class = "Standard"
}

resource "cloudflare_r2_bucket" "vaultwarden-backup" {
  account_id    = var.cloudflare_account_id
  name          = "vaultwarden-backup"
  location      = "apac"
  storage_class = "Standard"
}
