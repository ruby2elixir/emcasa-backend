defmodule Re.Tags.Queries do
  alias Re.Tag

  import Ecto.Query

  def filter_by(query \\ Tag, filters)

  def filter_by(query, nil), do: query

  def filter_by(query, filters) do
    Enum.reduce(filters, query, &filter_next/2)
  end

  def filter_next({:category, category}, query) do
    where(query, [t], t.category == ^category)
  end

  def filter_next({:name_slug_like, name_slug}, query) do
    where(query, [t], like(t.name_slug, ^"%#{name_slug}%"))
  end

  def filter_next({:name_slugs, name_slugs}, query) do
    where(query, [t], t.name_slug in ^name_slugs)
  end

  def filter_next({:uuid, uuid}, query) do
    where(query, [t], t.uuid == ^uuid)
  end

  def filter_next({:uuids, uuids}, query) do
    where(query, [t], t.uuid in ^uuids)
  end

  def filter_next({:visibility, visibility}, query) do
    where(query, [t], t.visibility == ^visibility)
  end
end
