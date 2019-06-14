defmodule Re.Repo.Migrations.AddUserUrlBuyerLeads do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :user_url, :string
    end
  end
end
