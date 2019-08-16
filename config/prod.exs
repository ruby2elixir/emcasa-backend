use Mix.Config

config :logger, :console, level: :info

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
  migration_source: "old_schema_migrations",
  types: Re.PostgresTypes

config :re_integrations, ReIntegrations.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("RE_INTEGRATIONS_POLL_SIZE")) || 10,
  ssl: true,
  migration_source: "re_integrations_schema_migrations",
  migration_default_prefix: "re_integrations"

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
  imovelweb_identity: System.get_env("IMOVELWEB_IDENTITY"),
  facebook_access_token: System.get_env("FACEBOOK_ACCESS_TOKEN"),
  garagem_url: System.get_env("GARAGEM_URL"),
  zapier_create_salesforce_lead_url: System.get_env("SALESFORCE_ZAPIER_URL"),
  zapier_create_salesforce_seller_lead_url: System.get_env("SALESFORCE_ZAPIER_SELLER_URL"),
  priceteller_url: System.get_env("PRICETELLER_URL"),
  priceteller_token: System.get_env("PRICETELLER_TOKEN"),
  aliketeller_url: System.get_env("ALIKETELLER_URL")

config :re_integrations,
  to: System.get_env("INTEREST_NOTIFICATION_EMAILS"),
  from: System.get_env("ADMIN_EMAIL"),
  frontend_url: System.get_env("FRONTEND_URL"),
  env: System.get_env("ENV"),
  reply_to: System.get_env("REPORT_REPLY_EMAIL"),
  credipronto_simulator_url: System.get_env("CREDIPRONTO_SIMULATOR_URL"),
  credipronto_account_id: System.get_env("CREDIPRONTO_ACCOUNT_ID"),
  grupozap_webhook_secret: System.get_env("GRUPOZAP_WEBHOOK_SECRET"),
  zapier_webhook_user: System.get_env("ZAPIER_WEBHOOK_USER"),
  zapier_webhook_pass: System.get_env("ZAPIER_WEBHOOK_PASS"),
  orulo_url: System.get_env("ORULO_URL"),
  orulo_api_token: System.get_env("ORULO_API_TOKEN"),
  orulo_client_token: System.get_env("ORULO_CLIENT_TOKEN"),
  routific_url: System.get_env("ROUTIFIC_URL"),
  routific_api_key: System.get_env("ROUTIFIC_API_KEY"),
  routific_job_url: System.get_env("ROUTIFIC_JOB_URL"),
  salesforce_event_owner_id: System.get_env("SALESFORCE_EVENT_OWNER_ID"),
  salesforce_api_key: System.get_env("SALESFORCE_API_KEY"),
  salesforce_url: System.get_env("SALESFORCE_URL"),
  google_calendar_acl: %{
    role: "owner",
    scope: %{
      type: System.get_env("GOOGLE_CALENDAR_ACL_OWNER_TYPE"),
      value: System.get_env("GOOGLE_CALENDAR_ACL_OWNER")
    }
  },
  salesforce_seller_lead_record_id: System.get_env("SALESFORCE_SELLER_LEAD_RECORD_ID")

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
  filter: ReWeb.SentryEventFilter,
  dsn: System.get_env("SENTRY_DSN")

config :prometheus, ReWeb.MetricsExporterPlug,
  auth: {:basic, System.get_env("PROMETHEUS_USER"), System.get_env("PROMETHEUS_PASS")}

config :cloudex,
  api_key: System.get_env("CLOUDINARY_API_KEY"),
  secret: System.get_env("CLOUDINARY_SECRET"),
  cloud_name: System.get_env("CLOUDINARY_CLOUD_NAME")

config :goth,
  json: {:system, "GCP_CREDENTIALS"}
