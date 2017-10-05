defmodule Re.Repo.Migrations.AddPhotoGmapsListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :photo, :string
      add :gmaps, :string
    end
  end
end
