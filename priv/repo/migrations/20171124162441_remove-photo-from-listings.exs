defmodule :"Elixir.Re.Repo.Migrations.Remove-photo-from-listings" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      remove :photo
    end
  end
end
