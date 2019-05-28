defmodule ReIntegrations.Repo do
  use Ecto.Repo,
    otp_app: :re_integrations,
    adapter: Ecto.Adapters.Postgres
end
