defmodule Re.Repo.Migrations.RemoveMessagesAndChannels do
  use Ecto.Migration

  def change do
    drop table(:messages)
    drop table(:channels)
  end
end
