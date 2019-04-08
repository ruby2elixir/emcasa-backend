defmodule Re.Tags.Queries do
  alias Re.Tag

  import Ecto.Query

  def get_public(query \\ Tag, uuid)

  def get_public(query, uuid) do
    query
    |> public()
    |> where([t], t.uuid == ^uuid)
  end

  def public(query \\ Tag) do
    from(t in query, where: t.visibility == "public")
  end

  def match_slug(query \\ Tag, name_slug)

  def match_slug(query, name_slug) do
    from(t in query, where: like(t.name_slug, ^"%#{name_slug}%"))
  end

  def with_uuids(query \\ Tag, uuids)

  def with_uuids(query, uuids), do: from(i in query, where: i.uuid in ^uuids)

  def with_slugs(query \\ Tag, slugs)

  def with_slugs(query, slugs), do: from(i in query, where: i.name_slug in ^slugs)
end
