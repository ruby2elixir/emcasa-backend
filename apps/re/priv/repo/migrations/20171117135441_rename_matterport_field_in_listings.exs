defmodule Re.Repo.Migrations.RenameMatterportFieldInListings do
  use Ecto.Migration

  def change do
    rename table(:listings), :matterport_url, to: :matterport_code
  end
end
