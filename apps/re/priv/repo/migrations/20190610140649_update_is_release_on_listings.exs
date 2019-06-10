defmodule Re.Repo.Migrations.UpdateIsReleaseOnListings do
  use Ecto.Migration

  require Ecto.Query

  def up do
    listing_ids =
      Ecto.Query.from(l in "listings", select: l.id, where: is_nil(l.is_release))
      |> Re.Repo.all()

    Ecto.Query.from(i in "listings",
      where: i.id in ^listing_ids
    )
    |> Re.Repo.update_all(set: [is_release: false])
  end

  def down do
  end
end
