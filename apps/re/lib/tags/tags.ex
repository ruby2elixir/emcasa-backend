defmodule Re.Tags do
  @moduledoc """
  Context for tags.
  """

  require Ecto.Query

  alias Re.{
    Tag,
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
