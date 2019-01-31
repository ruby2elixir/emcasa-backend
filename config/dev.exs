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
  username: "postgres",
  password: "postgres",
  database: "re_dev",
  hostname: "localhost",
  pool_size: 10

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer, adapter: Swoosh.Adapters.Local
