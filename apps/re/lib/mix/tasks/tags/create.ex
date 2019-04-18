defmodule Mix.Tasks.Re.Tags.Create do
  use Mix.Task

  require Logger

  @tags [
    %{category: "concierge", name: "24 Horas", visibility: "public"},
    %{category: "concierge", name: "Horario Comercial", visibility: "public"},
    %{category: "concierge", name: "Portaria Eletrônica", visibility: "public"},
    %{category: "infrastructure", name: "Academia", visibility: "public"},
    %{category: "infrastructure", name: "Bicicletário", visibility: "public"},
    %{category: "infrastructure", name: "Brinquedoteca", visibility: "public"},
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
    %{category: "realty", name: "Varanda Gourmet", visibility: "public"},
    %{category: "realty", name: "Varanda", visibility: "public"},
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

  def run(_) do
    Mix.EctoSQL.ensure_started(Re.Repo, [])

    Enum.map(@tags, &insert/1)
  end

  def insert(params) do
    {:ok, tag} =
      %Re.Tag{}
      |> Re.Tag.changeset(params)
      |> Re.Repo.insert(on_conflict: :nothing)

    Logger.info("insert : tag name #{tag.name_slug}")
  end
end
