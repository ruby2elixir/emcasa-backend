defmodule Re.Repo.Migrations.AddCategoryToImages do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add(:category, :string)
    end
  end
end
