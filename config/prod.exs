use Mix.Config

config :re_web, ReWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: System.get_env("HOST"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  check_origin: false

config :re_web, ReWeb.Guardian,
  allowed_algos: ["ES512"],
  secret_key: %{
    "alg" => "ES512",
    "crv" => "P-521",
    "d" => System.get_env("GUARDIAN_D"),
    "kty" => "EC",
    "use" => "sig",
    "x" => System.get_env("GUARDIAN_X"),
    "y" => System.get_env("GUARDIAN_Y")
  }

config :re, Re.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  migration_source: "old_schema_migrations"

config :re_integrations, ReIntegrations.Notifications.Emails.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SEND_GRID_API_KEY")

config :re,
  vivareal_highlights_size_rio_de_janeiro:
    String.to_integer(System.get_env("VIVAREAL_HIGHLIGHTS_SIZE_RIO_DE_JANEIRO")),
  vivareal_highlights_size_sao_paulo:
    String.to_integer(System.get_env("VIVAREAL_HIGHLIGHTS_SIZE_SAO_PAULO")),
  zap_highlights_size_rio_de_janeiro:
    String.to_integer(System.get_env("ZAP_HIGHLIGHTS_SIZE_RIO_DE_JANEIRO")),
  zap_highlights_size_sao_paulo:
    String.to_integer(System.get_env("ZAP_HIGHLIGHTS_SIZE_SAO_PAULO")),
  zap_super_highlights_size_rio_de_janeiro:
    String.to_integer(System.get_env("ZAP_SUPER_HIGHLIGHTS_SIZE_RIO_DE_JANEIRO")),
  zap_super_highlights_size_sao_paulo:
    String.to_integer(System.get_env("ZAP_SUPER_HIGHLIGHTS_SIZE_SAO_PAULO")),
  imovelweb_highlights_size_rio_de_janeiro:
    String.to_integer(System.get_env("IMOVELWEB_HIGHLIGHTS_SIZE_RIO_DE_JANEIRO")),
  imovelweb_highlights_size_sao_paulo:
    String.to_integer(System.get_env("IMOVELWEB_HIGHLIGHTS_SIZE_SAO_PAULO")),
  imovelweb_super_highlights_size_rio_de_janeiro:
    String.to_integer(System.get_env("IMOVELWEB_SUPER_HIGHLIGHTS_SIZE_RIO_DE_JANEIRO")),
  imovelweb_super_highlights_size_sao_paulo:
    String.to_integer(System.get_env("IMOVELWEB_SUPER_HIGHLIGHTS_SIZE_SAO_PAULO")),
  imovelweb_identity: System.get_env("IMOVELWEB_IDENTITY")

config :re_integrations,
  to: System.get_env("INTEREST_NOTIFICATION_EMAILS"),
  from: System.get_env("ADMIN_EMAIL"),
  frontend_url: System.get_env("FRONTEND_URL"),
  pipedrive_url: System.get_env("PIPEDRIVE_URL"),
  pipedrive_token: System.get_env("PIPEDRIVE_TOKEN"),
  pipedrive_webhook_user: System.get_env("PIPEDRIVE_WEBHOOK_USER"),
  pipedrive_webhook_pass: System.get_env("PIPEDRIVE_WEBHOOK_PASS"),
  env: System.get_env("ENV"),
  reply_to: System.get_env("REPORT_REPLY_EMAIL"),
  credipronto_simulator_url: System.get_env("CREDIPRONTO_SIMULATOR_URL"),
  credipronto_account_id: System.get_env("CREDIPRONTO_ACCOUNT_ID"),
  grupozap_webhook_secret: System.get_env("GRUPOZAP_WEBHOOK_SECRET")

config :re_integrations, ReIntegrations.Search.Cluster,
  url: System.get_env("ELASTICSEARCH_URL"),
  username: System.get_env("ELASTICSEARCH_KEY"),
  password: System.get_env("ELASTICSEARCH_SECRET")

config :pigeon, :fcm,
  fcm_default: %{
    key: System.get_env("FCM_TOKEN")
  }

config :account_kit,
  app_id: System.get_env("FACEBOOK_APP_ID"),
  app_secret: System.get_env("ACCOUNT_KIT_APP_SECRET")

config :sentry,
  dsn: System.get_env("SENTRY_DSN")
