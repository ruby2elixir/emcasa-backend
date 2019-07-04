defmodule Re.Repo.Migrations.AddInactivationReasonToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :inactivation_reason, :string
    end
  end
end
