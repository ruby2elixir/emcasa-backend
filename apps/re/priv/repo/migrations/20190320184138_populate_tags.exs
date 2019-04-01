defmodule Re.Repo.Migrations.PopulateTags do
  use Ecto.Migration

  def up do
    tags = [
      %{category: "infrastructure", name: "Academia", visibility: "all"},
      %{category: "infrastructure", name: "Churrasqueira", visibility: "all"},
      %{category: "infrastructure", name: "Espaço Gourmet", visibility: "all"},
      %{category: "infrastructure", name: "Espaço Verde", visibility: "all"},
      %{category: "infrastructure", name: "Parque", visibility: "all"},
      %{category: "infrastructure", name: "Piscina", visibility: "all"},
      %{category: "infrastructure", name: "Playground", visibility: "all"},
      %{category: "infrastructure", name: "Quadra", visibility: "all"},
      %{category: "infrastructure", name: "Salão De Festas", visibility: "all"},
      %{category: "infrastructure", name: "Salão De Jogos", visibility: "all"},
      %{category: "infrastructure", name: "Sauna", visibility: "all"},
      %{category: "realty", name: "Armários Embutidos", visibility: "all"},
      %{category: "realty", name: "Banheiro Empregados", visibility: "all"},
      %{category: "realty", name: "Bom Para Pets", visibility: "all"},
      %{category: "realty", name: "Dependência Empregados", visibility: "all"},
      %{category: "realty", name: "Espaço Para Churrasco", visibility: "all"},
      %{category: "realty", name: "Fogão Embutido", visibility: "all"},
      %{category: "realty", name: "Lavabo", visibility: "all"},
      %{category: "realty", name: "Reformado", visibility: "all"},
      %{category: "realty", name: "Sacada", visibility: "all"},
      %{category: "realty", name: "Terraço", visibility: "all"},
      %{category: "realty", name: "Vaga Na Escritura", visibility: "all"},
      %{category: "realty", name: "Varanda", visibility: "all"},
      %{category: "realty", name: "Varanda Gourmet", visibility: "all"},
      %{category: "view", name: "Comunidade", visibility: "admin"},
      %{category: "view", name: "Cristo", visibility: "all"},
      %{category: "view", name: "Lagoa", visibility: "all"},
      %{category: "view", name: "Mar", visibility: "all"},
      %{category: "view", name: "Montanhas", visibility: "all"},
      %{category: "view", name: "Parcial Comunidade", visibility: "admin"},
      %{category: "view", name: "Parcial Mar", visibility: "all"},
      %{category: "view", name: "Pedras", visibility: "all"},
      %{category: "view", name: "Verde", visibility: "all"},
      %{category: "view", name: "Vizinho", visibility: "admin"}
    ]

    Enum.map(tags, &Re.Tags.insert/1)
  end

  def down do
    Re.Repo.delete_all("tags")
  end
end
