defmodule Re.Repo.Migrations.AddZapHighlight do
  use Ecto.Migration

  def change do
    create table(:zap_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create unique_index(:zap_highlights, [:listing_id])
  end
end
