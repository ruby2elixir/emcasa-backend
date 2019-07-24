use Mix.Config

import_config "dev.secret.exs"

config :re_web, ReWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :logger, :console,
  format: "[$level] $message\n",
  truncate: :infinity

config :phoenix, :stacktrace_depth, 20

config :re, Re.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USERNAME") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: "re_dev",
  hostname: System.get_env("POSTGRES_HOSTNAME") || "localhost",
  pool_size: 10,
  migration_source: "old_schema_migrations",
  types: Re.PostgresTypes

config :re_integrations, ReIntegrations.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USERNAME") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: "re_dev",
  hostname: System.get_env("POSTGRES_HOSTNAME") || "localhost",
  pool_size: 10,
  migration_source: "re_integrations_schema_migrations",
  migration_default_prefix: "re_integrations"

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer,
  adapter: Swoosh.Adapters.Local
