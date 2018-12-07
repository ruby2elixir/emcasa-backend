defmodule Re.Repo.Migrations.AddStatusHistory do
  use Ecto.Migration

  def change do
    create table(:status_histories) do
      add(:status, :string)
      add(:listing_id, references(:listings))

      timestamps()
    end

    create(index(:status_histories, [:listing_id]))
  end
end
