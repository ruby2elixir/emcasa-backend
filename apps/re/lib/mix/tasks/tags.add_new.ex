defmodule Mix.Tasks.Re.Tags.AddNew do
  @moduledoc """
  Create new tags.
  """
  use Mix.Task

  @tags [
    %{category: "realty", name: "Closet", visibility: "public"}
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
