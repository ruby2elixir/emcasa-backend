defmodule :"Elixir.Re.Repo.Migrations.Remove-is-cloudinary-from-image" do
  use Ecto.Migration

  def change do
    alter table(:images) do
      remove :is_cloudinary
    end
  end
end
