defmodule Re.Repo.Migrations.RemoveOnlineSchedule do
  use Ecto.Migration

  def up do
    alter table(:interest_types) do
      add :enabled, :boolean
    end

    flush()

    Re.Repo.update_all(Re.InterestType, set: [enabled: true])

    flush()

    case Re.Repo.get_by(Re.InterestType, name: "Agendamento online") do
      nil ->
        Re.Repo.insert(%Re.InterestType{name: "Agendamento online", enabled: false})

      interest_type ->
        interest_type
        |> Re.InterestType.changeset(%{enabled: false})
        |> Re.Repo.update()
    end
  end

  def down do
    alter table(:interest_types) do
      remove :enabled
    end
  end
end
