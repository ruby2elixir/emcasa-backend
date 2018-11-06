defmodule Re.Repo.Migrations.AddZapSuperHighlight do
  use Ecto.Migration

  def change do
    create table(:zap_super_highlights) do
      add :listing_id, references(:listings)

      timestamps()
    end

    create unique_index(:zap_super_highlights, [:listing_id])
  end
end
