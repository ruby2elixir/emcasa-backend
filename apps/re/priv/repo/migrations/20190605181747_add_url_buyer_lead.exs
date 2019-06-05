defmodule Re.Repo.Migrations.AddUrlBuyerLead do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :url, :string
    end
  end
end
