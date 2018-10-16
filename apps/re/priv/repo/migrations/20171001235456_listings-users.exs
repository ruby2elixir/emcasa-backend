defmodule :"Elixir.Re.Repo.Migrations.Listings-users" do
  use Ecto.Migration

  def change do
    create table(:listings_users) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)
    end

    create index("listings_users", [:listing_id, :user_id])
  end
end
