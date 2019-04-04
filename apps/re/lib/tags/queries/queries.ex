defmodule Re.Tags.Queries do
  alias Re.Tag

  import Ecto.Query

  def public(query \\ Tag)

  def public(query) do
    from(i in query, where: i.visibility == "public")
  end

  def match_slug(query \\ Tag, name_slug)

  def match_slug(query, name_slug) do
    from(i in query, where: like(i.name_slug, ^"%#{name_slug}%"))
  end

  def with_uuids(query \\ Tag, uuids)

  def with_uuids(query, uuids), do: from(i in query, where: i.uuid in ^uuids)

  def with_slugs(query \\ Tag, slugs)

  def with_slugs(query, slugs), do: from(i in query, where: i.name_slug in ^slugs)
end
