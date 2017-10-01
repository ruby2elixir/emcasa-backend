defmodule :"Elixir.Re.Repo.Migrations.Listings-users" do
  use Ecto.Migration

  def change do
    create table(:listings_users, primary_key: false) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)
    end
  end
end
