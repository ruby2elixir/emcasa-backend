defmodule Re.Repo.Migrations.CreatePartnerBrokerRelation do
  use Ecto.Migration

  def change do
    create table(:brokers_districts, primary_key: false) do
      add :user_uuid, references(:users, column: :uuid, type: :uuid), primary_key: true
      add :district_uuid, references(:districts, column: :uuid, type: :uuid), primary_key: true
    end
  end
end
