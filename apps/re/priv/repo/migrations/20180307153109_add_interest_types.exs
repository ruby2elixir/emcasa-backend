defmodule Re.Repo.Migrations.AddInterestTypes do
  use Ecto.Migration

  def up do
    create table(:interest_types) do
      add :name, :string

      timestamps()
    end

    flush()

    alter table(:interests) do
      add :interest_type_id, references(:interest_types)
    end

    create(index(:interests, [:interest_type_id]))

    flush()

    Re.Repo.insert(%Re.InterestType{name: "Me ligue dentro de 5 minutos"})
    Re.Repo.insert(%Re.InterestType{name: "Me ligue em um horário específico"})
    Re.Repo.insert(%Re.InterestType{name: "Agendamento por e-mail"})
    Re.Repo.insert(%Re.InterestType{name: "Agendamento por Whatsapp"})
  end

  def down do
    alter table(:interests) do
      remove :interest_type_id
    end

    drop table(:interest_types)
  end
end
