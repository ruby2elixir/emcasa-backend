defmodule Re.Repo.Migrations.AddSoftDeleteToImage do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add(:is_active, :boolean)
    end
  end
end
