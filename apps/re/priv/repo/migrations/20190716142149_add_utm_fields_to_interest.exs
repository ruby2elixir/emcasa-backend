defmodule Re.Repo.Migrations.AddUtmFieldsToInterest do
  use Ecto.Migration

  def change do
    alter table(:interests) do
      add :campaign, :string
      add :medium, :string
      add :source, :string
      add :initial_campaign, :string
      add :initial_medium, :string
      add :initial_source, :string
    end
  end
end
