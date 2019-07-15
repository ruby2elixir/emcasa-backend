defmodule Mix.Tasks.Re.Tags.AddNew do
  @moduledoc """
  Create new tags.
  """
  use Mix.Task

  @tags [
    %{category: "infrastructure", name: "Destaque", visibility: "private"}
  ]

  alias Re.{
    Tag,
    Repo
  }

  @shortdoc "Create new tags"

  def run(_) do
    Mix.Task.run("app.start")

    Enum.map(@tags, &insert/1)
  end

  def insert(params) do
    {:ok, tag} =
      %Re.Tag{}
      |> Tag.changeset(params)
      |> Repo.insert(on_conflict: :nothing)

    Mix.shell().info("insert : tag name #{tag.name_slug}")
  end
end
