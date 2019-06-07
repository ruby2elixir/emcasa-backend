defmodule Re.Repo.Migrations.CreateBudgetBuyerLead do
  use Ecto.Migration

  def change do
    create table(:budget_buyer_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :state, :string
      add :city, :string
      add :neighborhood, :string
      add :budget, :string

      add :state_slug, :string
      add :city_slug, :string

      add :user_uuid, references(:users, column: :uuid, type: :uuid)

      timestamps(type: :timestamptz)
    end

    create index(:budget_buyer_leads, [:user_uuid])
  end
end
