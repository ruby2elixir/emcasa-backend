defmodule Re.Repo.Migrations.GeneratePerdizesSlugs do
  use Ecto.Migration

  def change do
    import Ecto.Query

    from(d in Re.Addresses.District,
      where: d.state == "SP" and d.city == "São Paulo" and d.name == "Perdizes"
    )
    |> Re.Repo.one()
    |> Re.Addresses.District.changeset()
    |> Re.Repo.update()
  end
end
