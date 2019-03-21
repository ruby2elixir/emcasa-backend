defmodule Re.Tags do
  @moduledoc """
  Context for tags.
  """

  require Ecto.Query

  alias Re.{
    Tag,
    Tags.Queries,
    Repo
  }

  def all do
    Tag
    |> Re.Repo.all()
  end

  def get(id) do
    case Repo.get(Tag, id) do
      nil -> {:error, :not_found}
      tag -> {:ok, tag}
    end
  end

  def list_by_ids(uuids) do
    uuids
    |> Queries.with_ids()
    |> Repo.all()
  end

  def list_by_slugs(slugs) do
    slugs
    |> Queries.with_slugs()
    |> Repo.all()
  end

  def insert(params) do
    %Tag{}
    |> change(params)
    |> Repo.insert()
  end

  def update(tag, params) do
    tag
    |> change(params)
    |> Repo.update()
  end

  defp change(instance, params) do
    instance
    |> Tag.changeset(params)
  end
end
