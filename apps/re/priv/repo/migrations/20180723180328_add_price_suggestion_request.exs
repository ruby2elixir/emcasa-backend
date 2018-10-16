defmodule Re.Repo.Migrations.AddPriceSuggestionRequest do
  use Ecto.Migration

  def change do
    create table(:price_suggestion_requests) do
      add :name, :string
      add :email, :string

      add :area, :integer
      add :rooms, :integer
      add :bathrooms, :integer
      add :garage_spots, :integer

      add :address_id, references(:addresses)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:price_suggestion_requests, [:address_id])
    create index(:price_suggestion_requests, [:user_id])
  end
end
