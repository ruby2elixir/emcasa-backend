defmodule Re.Repo do
  use Ecto.Repo,
    otp_app: :re,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20

  Postgrex.Types.define(
    Re.PostgresTypes,
    [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
    json: Poison
  )
end
