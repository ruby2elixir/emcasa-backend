defmodule Re.Repo.Migrations.GenerateUserUuids do
  use Ecto.Migration

  def up do
    Re.User
    |> Re.Repo.all()
    |> Enum.map(&Re.User.uuid_changeset(&1, %{uuid: UUID.uuid4()}))
    |> Enum.each(&Re.Repo.update/1)
  end

  def down, do: :ok
end
