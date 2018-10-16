defmodule Re.Repo.Migrations.DefaultGarageSpots do
  use Ecto.Migration

  import Ecto.Query

  def change do
    Re.Listing
    |> where([l], is_nil(l.garage_spots))
    |> Re.Repo.update_all(set: [garage_spots: 0])
  end
end
