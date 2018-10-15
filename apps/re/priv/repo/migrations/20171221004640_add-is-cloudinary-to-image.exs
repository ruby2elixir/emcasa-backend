defmodule :"Elixir.Re.Repo.Migrations.Add-is-cloudinary-to-image" do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :is_cloudinary, :boolean, default: false
    end
  end
end
