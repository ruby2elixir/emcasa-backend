defmodule Re.Repo.Migrations.AddMatterportToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :matterport_url, :string
    end
  end
end
