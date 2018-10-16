defmodule Re.Repo.Migrations.ConvertLatLngToFloat do
  use Ecto.Migration

  def up do
    alter table(:addresses) do
      add(:lat_float, :float)
      add(:lng_float, :float)
    end

    flush()

    execute("UPDATE addresses set lat_float = cast(lat as double precision) ;")
    execute("UPDATE addresses set lng_float = cast(lng as double precision) ;")

    flush()

    alter table(:addresses) do
      remove(:lat)
      remove(:lng)
    end

    flush()

    rename(table(:addresses), :lat_float, to: :lat)
    rename(table(:addresses), :lng_float, to: :lng)
  end

  def down do
    alter table(:addresses) do
      add(:lat_string, :string)
      add(:lng_string, :string)
    end

    flush()

    execute("UPDATE addresses set lat_string = cast(lat as varchar) ;")
    execute("UPDATE addresses set lng_string = cast(lng as varchar) ;")

    flush()

    alter table(:addresses) do
      remove(:lat)
      remove(:lng)
    end

    flush()

    rename(table(:addresses), :lat_string, to: :lat)
    rename(table(:addresses), :lng_string, to: :lng)
  end
end
