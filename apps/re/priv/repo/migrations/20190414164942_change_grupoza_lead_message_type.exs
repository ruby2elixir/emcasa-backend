defmodule Re.Repo.Migrations.ChangeGrupozaLeadMessageType do
  use Ecto.Migration

  def up do
    alter table(:grupozap_buyer_leads) do
      modify(:message, :text)
    end
  end

  def down do
    alter table(:grupozap_buyer_leads) do
      modify(:message, :string)
    end
  end
end
