defmodule Re.Repo.Migrations.AddInactivationReasonToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :inactivation_reason, :string
      add :sold_price, :integer
    end
  end
end
