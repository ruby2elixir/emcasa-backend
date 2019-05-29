defmodule Re.Repo.Migrations.AddBuyerLeadsBudgetField do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :budget, :string
    end
  end
end
