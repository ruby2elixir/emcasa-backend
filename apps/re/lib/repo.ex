defmodule Re.Repo do
  use Ecto.Repo,
    otp_app: :re,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20

  alias Ecto.Adapters.Postgres
  alias Geo.PostGIS.Extension

  Postgrex.Types.define(
    Re.PostgresTypes,
    [Extension] ++ Postgres.extensions(),
    json: Jason
  )
end
