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
  username: "postgres",
  password: "postgres",
  database: "re_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :account_kit,
  app_id: "123"

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer,
  adapter: Swoosh.Adapters.Test

config :re,
  visualizations: Re.TestVisualizations,
  account_kit: Re.TestAccountKit

config :re_integrations,
  http: ReIntegrations.TestHTTP,
  credipronto_simulator_url: "http://www.emcasa.com/simulator",
  credipronto_account_id: "test_account_id"

config :re_web,
  pipedrive_webhook_user: "testuser",
  pipedrive_webhook_pass: "testpass"

config :honeybadger,
  environment_name: :test
