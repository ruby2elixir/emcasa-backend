defmodule Mix.Tasks.Re.Tags.AddNew do
  @moduledoc """
  Create new tags.
  """
  use Mix.Task

  @tags [
    %{category: "realty", name: "Armário Na Cozinha", visibility: "public"},
    %{category: "realty", name: "Armário No Quarto", visibility: "public"},
    %{category: "realty", name: "Área De Serviço", visibility: "public"},
    %{category: "realty", name: "Primeira Quadra Da Praia", visibility: "public"},
    %{category: "realty", name: "Mobiliado", visibility: "public"},
    %{category: "realty", name: "Piso De madeira", visibility: "public"},
    %{category: "realty", name: "Piso Porcelanato", visibility: "public"},
    %{category: "realty", name: "Piso De Cerâmica", visibility: "public"},
    %{category: "realty", name: "Piso De Granito", visibility: "public"},
    %{category: "realty", name: "Banheiro Com Box", visibility: "public"},
    %{category: "realty", name: "Cozinha Americana", visibility: "public"}
  ]

  alias Re.{
    Repo,
    Tag
  }

  @shortdoc "Create new tags"

  def run(_) do
    Mix.Task.run("app.start")

    Enum.each(@tags, &insert/1)
  end

  def insert(params) do
    %Re.Tag{}
    |> Tag.changeset(params)
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, tag} ->
        Mix.shell().info("Successfully inserted tag #{tag.name_slug}")

      {:error, error} ->
        Mix.shell().info("Failed to insert new tag, error: #{error}")
    end
  end
end
