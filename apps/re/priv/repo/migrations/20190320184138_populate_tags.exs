defmodule Re.Repo.Migrations.PopulateTags do
  use Ecto.Migration

  def up do
    [
      "Bicicletário",
      "Salão de Jogos",
      "Parque",
      "Espaço verde",
      "Espaço gourmet",
      "Quadra",
      "Playground",
      "Sauna",
      "Academia",
      "Salão de festas",
      "Churrasqueira",
      "Piscina"
    ]
    |> Enum.map(fn name -> %{category: "infrastructure", name: name} end)
    |> Enum.map(&Re.Tags.insert/1)
  end

  def down do
    Re.Repo.delete_all("tags")
  end
end
