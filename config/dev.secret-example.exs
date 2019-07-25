use Mix.Config

# To generate api_key for Sendgrid, open a free SendGrid account
# at sendgrid.com and generate a personal api key.
# https://app.sendgrid.com/settings/api_keys
#
# To generate keys for Guardian, open an iex session in the terminal with:
# iex -S mix phx.server
# then run
# JOSE.JWS.generate_key(%{"alg" => "ES512"}) |> JOSE.JWK.to_map |> elem(1)
# and copy the hashes for "d", "x", and "y".

config :re_web, ReWeb.Guardian,
  allowed_algos: ["ES512"],
  secret_key: %{
    "alg" => "ES512",
    "crv" => "P-521",
    "d" => "xxxxxx",
    "kty" => "EC",
    "use" => "sig",
    "x" => "xxxxxx",
    "y" => "xxxxxx"
  }

config :re_integrations,
  to: "dev1@email.com|dev2@email.com",
  from: "admin@email.com",
  credipronto_simulator_url: "CREDIPRONTO_URL",
  credipronto_account_id: "CREDIPRONTO_ACCOUNT_ID",
  grupozap_webhook_secret: "grupozap_secret",
  zapier_webhook_user: "testuser",
  zapier_webhook_pass: "testpass",
  orulo_url: "orulo_url",
  orulo_api_token: "orulo_api_token",
  orulo_client_token: "orulo_client_token"

config :re,
  vivareal_highlights_size_rio_de_janeiro: 10,
  vivareal_highlights_size_sao_paulo: 10,
  zap_highlights_size_rio_de_janeiro: 10,
  zap_highlights_size_sao_paulo: 10,
  zap_super_highlights_size_rio_de_janeiro: 5,
  zap_super_highlights_size_sao_paulo: 5,
  imovelweb_highlights_size_rio_de_janeiro: 10,
  imovelweb_highlights_size_sao_paulo: 10,
  imovelweb_super_highlights_size_rio_de_janeiro: 10,
  imovelweb_super_highlights_size_sao_paulo: 10,
  imovelweb_identity: "1",
  facebook_access_token: "FACEBOOK_ACCESS_TOKEN",
  garagem_url: "localhost",
  zapier_create_salesforce_lead_url: "SALESFORCE_ZAPIER_URL",
  priceteller_url: "priceteller_url",
  priceteller_token: "mahtoken"

config :account_kit,
  app_id: "your_dev_app_id",
  app_secret: "your_dev_app_secret",
  require_appsecret: false,
  api_version: "v1.0"

config :cloudex,
  api_key: "api_key",
  secret: "secret",
  cloud_name: "cloud"

config :goth,
  json: Path.expand("dev.service-account-example.json") |> File.read!()
