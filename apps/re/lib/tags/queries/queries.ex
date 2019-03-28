defmodule Re.Tags.Queries do
  alias Re.Tag

  import Ecto.Query

  def with_uuids(query \\ Tag, uuids)

  def with_uuids(query, uuids), do: from(i in query, where: i.uuid in ^uuids)

  def with_slugs(query \\ Tag, slugs)

  def with_slugs(query, slugs), do: from(i in query, where: i.name_slug in ^slugs)
end
