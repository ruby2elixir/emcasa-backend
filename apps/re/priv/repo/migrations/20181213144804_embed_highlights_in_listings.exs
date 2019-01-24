defmodule Re.Repo.Migrations.EmbedHighlightsInListings do
  use Ecto.Migration

  alias Re.{
    Listing,
    Listings.Highlights.Vivareal,
    Repo
  }

  def up do
    import Ecto.Query

    alter table(:listings) do
      add :vivareal_highlight, :boolean
    end

    flush()

    Vivareal
    |> preload(:listing)
    |> Repo.all()
    |> Enum.map(fn hl -> hl.listing end)
    |> Enum.each(fn listing ->
      listing |> Listing.changeset(%{vivareal_highlight: true}, "admin") |> Repo.update()
    end)

    drop table(:vivareal_highlights)
  end

  def down do
    import Ecto.Query

    create table(:vivareal_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create index(:vivareal_highlights, [:listing_id])

    flush()

    Re.Listing
    |> where([l], l.vivareal_highlight)
    |> Repo.all()
    |> Enum.each(fn listing ->
      %Vivareal{} |> Vivareal.changeset(%{listing_id: listing.id}) |> Repo.insert()
    end)

    alter table(:listings) do
      remove :vivareal_highlight
    end
  end
end
