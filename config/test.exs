use Mix.Config

config :re_web, ReWeb.Endpoint,
  http: [port: 4001],
  server: false,
  env: "test"

config :logger, level: :warn

config :re_web, ReWeb.Guardian,
  allowed_algos: ["ES512"],
  secret_key: %{
    "alg" => "ES512",
    "crv" => "P-521",
    "d" =>
      "W9YqJjm9e452o7dPksq6vBZepwd8a4jZFW_t-UIDMUF06kd1dLsxpKXpk8APuK-d5J-50HF4BdAGjmJpPkpOQ1U",
    "kty" => "EC",
    "use" => "sig",
    "x" =>
      "AaGpyKIkI5oDXfdBuGEEIUnARSlUFiYx0fwwXqgQy4qyNthel0Rk8bFTwR4_R7yr7FN5lu9DY2G3Yyhr13b9F2e4",
    "y" =>
      "ABHa0GzAhxsmJkS5JvFMk3MHIoG4jw1MNigpzU6LyBWO9zWFQ636J9H0mOISk835dkqws_MKOND4EeRhlbIHZRP7"
  }

config :re, Re.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USERNAME") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: "re_test",
  port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432"),
  hostname: System.get_env("POSTGRES_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_source: "old_schema_migrations"

config :re_integrations, ReIntegrations.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USERNAME") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: "re_test",
  port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432"),
  hostname: System.get_env("POSTGRES_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_source: "re_integrations_schema_migrations",
  migration_default_prefix: "re_integrations"

config :account_kit,
  app_id: "123"

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer, adapter: Swoosh.Adapters.Test

config :re,
  visualizations: Re.TestVisualizations,
  account_kit: Re.TestAccountKit,
  http: Re.TestHTTP,
  vivareal_highlights_size_rio_de_janeiro: 10,
  vivareal_highlights_size_sao_paulo: 10,
  zap_highlights_size_rio_de_janeiro: 10,
  zap_highlights_size_sao_paulo: 10,
  zap_super_highlights_size_rio_de_janeiro: 5,
  zap_super_highlights_size_sao_paulo: 5,
  imovelweb_highlights_size_rio_de_janeiro: 5,
  imovelweb_highlights_size_sao_paulo: 5,
  imovelweb_super_highlights_size_rio_de_janeiro: 5,
  imovelweb_super_highlights_size_sao_paulo: 5,
  imovelweb_identity: "1",
  facebook_access_token: "testsecret",
  garagem_url: "http://localhost:3000",
  zapier_create_salesforce_lead_url: "http://www.emcasa.com/salesforce_zapier",
  zapier_create_salesforce_seller_lead_url: "http://www.emcasa.com/salesforce_zapier",
  priceteller_url: "http://www.emcasa.com/priceteller",
  priceteller_token: "mahtoken",
  aliketeller_url: "http://www.emcasa.com/aliketeller",
  retry_expiry: 100

config :re_integrations,
  http: ReIntegrations.TestHTTP,
  goth_token: ReIntegrations.TestGoth.Token,
  credipronto_simulator_url: "http://www.emcasa.com/simulator",
  credipronto_account_id: "test_account_id",
  grupozap_webhook_secret: "testsecret",
  zapier_webhook_user: "testuser",
  zapier_webhook_pass: "testpass",
  cloudinary_client: ReIntegrations.TestCloudex,
  orulo_url: "http://www.emcasa.com/orulo",
  tour_visit_duration: 60,
  google_calendar_acl: %{
    role: "owner",
    scope: %{
      type: "domain",
      value: "example.com"
    }
  },
  salesforce_seller_lead_record_id: "0x01",
  zapier_schedule_visits_url: "https://example.com/zapier/webhook"

config :junit_formatter,
  report_file: "report_file_test.xml",
  print_report_file: true

config :cloudex,
  api_key: "api_key",
  secret: "secret",
  cloud_name: "cloud"

config :goth,
  disabled: true

config :tesla,
  adapter: Tesla.Mock
