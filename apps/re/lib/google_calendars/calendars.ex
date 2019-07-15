defmodule Re.GoogleCalendars.Calendars do
  @moduledoc """
  Context for developments.
  """
  @behaviour Bodyguard.Policy

  require Ecto.Query

  alias Ecto.{
    Changeset,
    Multi
  }

  alias Re.{
    GoogleCalendars.Calendar,
    Repo
  }

  defdelegate authorize(action, user, params), to: Re.GoogleCalendars.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Calendar

  def all do
    Calendar
    |> Re.Repo.all()
  end

  def get(uuid), do: do_get(Calendar, uuid)

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
    |> Repo.preload(:districts)
    |> Calendar.changeset_update_districts(districts)
    |> Repo.update()
  end
end
