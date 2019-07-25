defmodule Mix.Tasks.Re.Tags.AddNew do
  @moduledoc """
  Create new tags.
  """
  use Mix.Task

  @tags [
    %{category: "ops", name: "Temos Chave", visibility: "private"},
    %{category: "ops", name: "Desocupado", visibility: "private"},
    %{category: "ops", name: "Placa De Contato", visibility: "private"},
    %{category: "ops", name: "Exclusivo", visibility: "private"}
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
