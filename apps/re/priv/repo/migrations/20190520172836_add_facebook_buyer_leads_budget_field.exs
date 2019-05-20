defmodule Re.Repo.Migrations.AddFacebookBuyerLeadsBudgetField do
  use Ecto.Migration

  def change do
    alter table(:facebook_buyer_leads) do
      add :budget, :string
    end
  end
end
