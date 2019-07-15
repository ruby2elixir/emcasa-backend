defmodule Re.GoogleCalendars do
  @moduledoc """
  Context for google calendars.
  """

  require Ecto.Query

  alias Re.{
    GoogleCalendars.Calendar,
    GoogleCalendars.Calendar.Queries,
    Repo
  }

  def all, do: Calendar |> Re.Repo.all()

  def get(uuid), do: do_get(Calendar, uuid)

  def get_preloaded(uuid), do: Calendar |> Queries.preload_relations() |> do_get(uuid)

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end

  def insert(params) do
    %Calendar{}
    |> Calendar.changeset(params)
    |> Repo.insert()
  end

  def upsert_districts(calendar, districts) do
    calendar
    |> Repo.preload([:districts])
    |> Calendar.changeset_update_districts(districts)
    |> Repo.update()
  end
end
