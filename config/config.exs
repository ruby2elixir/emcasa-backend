use Mix.Config

config :re,
  ecto_repos: [Re.Repo],
  use_logger: true

config :re_integrations,
  ecto_repos: [ReIntegrations.Repo],
  frontend_url: "http://localhost:3000",
  to: "dev1@email.com|dev2@email.com",
  from: "admin@email.com",
  reply_to: "admin@email.com",
  env: "dev",
  use_logger: true,
  timezone: System.get_env("TIMEZONE")

config :re_web, ReWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AFa6xCBxoVrAjCy3YRiSjY9e1TfUn75VT2QhSALdwJ+q/oA693/5mJ0OKptYSIID",
  render_errors: [view: ReWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ReWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [ReWeb.PlugPipelineInstrumenter, ReWeb.Endpoint.PhoenixInstrumenter]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :re_web, ReWeb.Guardian,
  allowed_algos: ["HS256"],
  issuer: "Re",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: "MDLMflIpKod5YCnkdiY7C4E3ki2rgcAAMwfBl0+vyC5uqJNgoibfQmAh7J3uZWVK",
  serializer: Re.GuardianSerializer

config :comeonin, :bcrypt_log_rounds, 4

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "SG.x.x"

config :email_checker, validations: [EmailChecker.Check.Format]

config :re_integrations, ReIntegrations.Search.Cluster,
  url: "http://#{System.get_env("ELASTICSEARCH_HOSTNAME") || "localhost"}:9200",
  api: Elasticsearch.API.HTTP,
  json_library: Poison,
  indexes: %{
    listings: %{
      settings: "priv/elasticsearch/listings.json",
      store: ReIntegrations.Search.Store,
      sources: [Re.Listing],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }

config :currency_formatter, :whitelist, ["BRL"]

config :account_kit,
  api_version: "v1.0",
  require_appsecret: false

config :mime, :types, %{
  "application/xml" => ["xml"]
}

config :phoenix, :json_library, Jason

config :sentry,
  included_environments: ~w(production staging),
  environment_name: System.get_env("ENV") || "development"

config :geo_postgis,
  json_library: Jason

config :prometheus, ReWeb.PlugExporter,
  path: "/metrics",
  format: :auto,
  registry: :default,
  auth: false

config :re, Re.AlikeTeller.Scheduler,
  debug_logging: false,
  jobs: [
    {"@daily", {Re.AlikeTeller, :load, []}}
  ]

config :re_integrations, ReIntegrations.Salesforce.Scheduler,
  debug_logging: false,
  timezone: System.get_env("TIMEZONE") || "Etc/UTC",
  jobs: [
    {"1 0 * * *", {ReIntegrations.Salesforce.Scheduler, :schedule_daily_visits, []}}
  ]

import_config "#{Mix.env()}.exs"

import_config "timber.exs"
