defmodule Re.Calendars do
  @moduledoc """
  Context module for calendars
  """
  alias Re.{
    Calendars.TourAppointment,
    Repo
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def schedule_tour(params) do
    %TourAppointment{}
    |> TourAppointment.changeset(params)
    |> Repo.insert()
  end
end
