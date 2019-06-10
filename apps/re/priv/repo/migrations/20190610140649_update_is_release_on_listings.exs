defmodule Re.Repo.Migrations.UpdateIsReleaseOnListings do
  use Ecto.Migration

  require Ecto.Query

  def up do
    listing_ids =
      "listings"
      |> Ecto.Query.from([l], select: l.id, where: is_nil(l.is_release))
      |> Re.Repo.all()

    "listings"
    |> Ecto.Query.from([l],
      where: l.id in ^listing_ids
    )
    |> Re.Repo.update_all(set: [is_release: false])
  end

  def down do
  end
end
