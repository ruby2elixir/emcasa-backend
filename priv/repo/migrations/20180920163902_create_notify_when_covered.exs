defmodule Re.Repo.Migrations.CreateNotifyWhenCovered do
  use Ecto.Migration

  def change do
    create table(:notify_when_covered) do
      add(:name, :string)
      add(:email, :string)
      add(:phone, :string)
      add(:message, :text)

      add(:user_id, references(:users))
      add(:address_id, references(:addresses))

      timestamps()
    end

    create(index(:notify_when_covered, [:user_id]))
    create(index(:notify_when_covered, [:address_id]))
  end
end
