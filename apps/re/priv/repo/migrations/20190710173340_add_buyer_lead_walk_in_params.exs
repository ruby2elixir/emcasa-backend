defmodule Re.Repo.Migrations.AddBuyerLeadWalkInParams do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :cpf, :string
      add :where_did_you_find_about, :string
    end
  end
end
