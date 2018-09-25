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

  def format_datetime(datetime) do
    day_name =
      datetime
      |> Timex.weekday()
      |> day_name()

    formatted_day = Timex.format(datetime, "{D}-{M}-{YY}")

    "#{day_name}, #{formatted_day}"
  end

  defp day_name(1), do: "Segunda-feira"
  defp day_name(2), do: "Terça-feira"
  defp day_name(3), do: "Quarta-feira"
  defp day_name(4), do: "Quinta-feira"
  defp day_name(5), do: "Sexta-feira"
  defp day_name(6), do: "Sábado"
  defp day_name(7), do: "Domingo"
  defp day_name(_), do: {:error, :invalid_weekday_number}
end
