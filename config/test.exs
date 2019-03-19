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
  port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432") ,
  hostname: System.get_env("POSTGRES_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_source: "old_schema_migrations"

config :account_kit,
  app_id: "123"

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer, adapter: Swoosh.Adapters.Test

config :re,
  visualizations: Re.TestVisualizations,
  account_kit: Re.TestAccountKit,
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
  imovelweb_identity: "1"

config :re_integrations,
  http: ReIntegrations.TestHTTP,
  credipronto_simulator_url: "http://www.emcasa.com/simulator",
  credipronto_account_id: "test_account_id",
  pipedrive_webhook_user: "testuser",
  pipedrive_webhook_pass: "testpass"
