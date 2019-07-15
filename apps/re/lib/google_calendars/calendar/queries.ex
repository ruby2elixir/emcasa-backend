defmodule Re.GoogleCalendars.Calendar.Queries do
  @moduledoc """
  Module for grouping developments queries
  """

  alias Re.{
    Slugs,
    GoogleCalendars.Calendar
  }

  import Ecto.Query

  @relations [:districts]

  def preload_relations(query \\ Calendar, relations \\ @relations)

  def preload_relations(query, relations), do: preload(query, ^relations)

  def by_districts(query \\ Calendar, district_names_or_slugs) do
    district_slugs = district_names_or_slugs |> Enum.map(&Slugs.sluggify/1)

    from(
      c in query,
      join: d in assoc(c, :districts),
      where: d.name_slug in ^district_slugs,
      distinct: c.uuid
    )
  end
end
