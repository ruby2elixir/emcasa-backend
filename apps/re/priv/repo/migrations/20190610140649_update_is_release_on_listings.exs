defmodule Re.Repo.Migrations.UpdateIsReleaseOnListings do
  use Ecto.Migration

  require Ecto.Query

  def up do
    "listings"
    |> Ecto.Query.where([l], is_nil(l.is_release))
    |> Re.Repo.update_all(set: [is_release: false])
  end

  def down do
  end
end
