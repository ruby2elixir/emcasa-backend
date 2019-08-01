defmodule Re.Repo.Migrations.DropInterestTypes do
  use Ecto.Migration

  def change do
    alter table(:interests) do
      remove :interest_type_id
    end

    flush()

    drop table(:interest_types)
  end
end
