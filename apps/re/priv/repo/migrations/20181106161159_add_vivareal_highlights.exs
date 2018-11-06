defmodule Re.Repo.Migrations.AddVivarealHighlights do
  use Ecto.Migration

  def change do
    create table(:vivareal_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create unique_index(:vivareal_highlights, [:listing_id])
  end
end
