defmodule Re.Repo.Migrations.EmbedHighlightsInListings do
  use Ecto.Migration

  alias Re.{
    Listing,
    Listings.Highlights.Zap,
    Listings.Highlights.ZapSuper,
    Listings.Highlights.Vivareal,
    Repo
  }

  def up do
    import Ecto.Query

    alter table(:listings) do
      add :zap_highlight, :boolean
      add :zap_super_highlight, :boolean
      add :vivareal_highlight, :boolean
    end

    flush()

    Zap
    |> preload(:listing)
    |> Repo.all()
    |> Enum.map(fn hl -> hl.listing end)
    |> Enum.each(fn listing ->
      listing |> Listing.changeset(%{zap_highlight: true}, "admin") |> Repo.update()
    end)

    ZapSuper
    |> preload(:listing)
    |> Repo.all()
    |> Enum.map(fn hl -> hl.listing end)
    |> Enum.each(fn listing ->
      listing |> Listing.changeset(%{zap_super_highlight: true}, "admin") |> Repo.update()
    end)

    Vivareal
    |> preload(:listing)
    |> Repo.all()
    |> Enum.map(fn hl -> hl.listing end)
    |> Enum.each(fn listing ->
      listing |> Listing.changeset(%{vivareal_highlight: true}, "admin") |> Repo.update()
    end)

    drop table(:zap_highlights)
    drop table(:zap_super_highlights)
    drop table(:vivareal_highlights)
  end

  def down do
    import Ecto.Query

    create table(:zap_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create table(:zap_super_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create table(:vivareal_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create index(:zap_highlights, [:listing_id])
    create index(:zap_super_highlights, [:listing_id])
    create index(:vivareal_highlights, [:listing_id])

    flush()

    Re.Listing
    |> where([l], l.zap_highlight)
    |> Repo.all()
    |> Enum.each(fn listing ->
      %Zap{} |> Zap.changeset(%{listing_id: listing.id}) |> Repo.insert()
    end)

    Re.Listing
    |> where([l], l.zap_super_highlight)
    |> Repo.all()
    |> Enum.each(fn listing ->
      %ZapSuper{} |> ZapSuper.changeset(%{listing_id: listing.id}) |> Repo.insert()
    end)

    Re.Listing
    |> where([l], l.vivareal_highlight)
    |> Repo.all()
    |> Enum.each(fn listing ->
      %Vivareal{} |> Vivareal.changeset(%{listing_id: listing.id}) |> Repo.insert()
    end)

    alter table(:listings) do
      remove :zap_highlight
      remove :zap_super_highlight
      remove :vivareal_highlight
    end
  end
end
