defmodule :"Elixir.Re.Repo.Migrations.Add-password-to-users" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
    end
  end
end
