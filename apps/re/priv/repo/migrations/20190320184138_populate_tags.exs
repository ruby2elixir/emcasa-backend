defmodule Re.Repo.Migrations.PopulateTags do
  use Ecto.Migration

  def up do
    tags = [
      %{category: "infrastructure", name: "Academia", visibility: "public"},
      %{category: "infrastructure", name: "Churrasqueira", visibility: "public"},
      %{category: "infrastructure", name: "Espaço Gourmet", visibility: "public"},
      %{category: "infrastructure", name: "Espaço Verde", visibility: "public"},
      %{category: "infrastructure", name: "Parque", visibility: "public"},
      %{category: "infrastructure", name: "Piscina", visibility: "public"},
      %{category: "infrastructure", name: "Playground", visibility: "public"},
      %{category: "infrastructure", name: "Quadra", visibility: "public"},
      %{category: "infrastructure", name: "Salão De Festas", visibility: "public"},
      %{category: "infrastructure", name: "Salão De Jogos", visibility: "public"},
      %{category: "infrastructure", name: "Sauna", visibility: "public"},
      %{category: "realty", name: "Armários Embutidos", visibility: "public"},
      %{category: "realty", name: "Banheiro Empregados", visibility: "public"},
      %{category: "realty", name: "Bom Para Pets", visibility: "public"},
      %{category: "realty", name: "Dependência Empregados", visibility: "public"},
      %{category: "realty", name: "Espaço Para Churrasco", visibility: "public"},
      %{category: "realty", name: "Fogão Embutido", visibility: "public"},
      %{category: "realty", name: "Lavabo", visibility: "public"},
      %{category: "realty", name: "Reformado", visibility: "public"},
      %{category: "realty", name: "Sacada", visibility: "public"},
      %{category: "realty", name: "Terraço", visibility: "public"},
      %{category: "realty", name: "Vaga Na Escritura", visibility: "public"},
      %{category: "realty", name: "Varanda", visibility: "public"},
      %{category: "realty", name: "Varanda Gourmet", visibility: "public"},
      %{category: "view", name: "Comunidade", visibility: "private"},
      %{category: "view", name: "Cristo", visibility: "public"},
      %{category: "view", name: "Lagoa", visibility: "public"},
      %{category: "view", name: "Mar", visibility: "public"},
      %{category: "view", name: "Montanhas", visibility: "public"},
      %{category: "view", name: "Parcial Comunidade", visibility: "private"},
      %{category: "view", name: "Parcial Mar", visibility: "public"},
      %{category: "view", name: "Pedras", visibility: "public"},
      %{category: "view", name: "Verde", visibility: "public"},
      %{category: "view", name: "Vizinho", visibility: "private"}
    ]

    Enum.map(tags, &Re.Tags.insert/1)
  end

  def down do
    Re.Repo.delete_all("tags")
  end
end
