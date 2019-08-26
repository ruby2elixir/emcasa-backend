defmodule Re.Calendars.Calendar.Queries do
  @moduledoc """
  Module for grouping developments queries
  """

  alias Re.{
    Calendars.Calendar,
    Slugs
  }

  import Ecto.Query

  @relations [:address]

  def preload_relations(query \\ Calendar, relations \\ @relations)

  def preload_relations(query, relations), do: preload(query, ^relations)
end
