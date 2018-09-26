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

  @format "{D}-{M}-{YYYY} {h12}:{m} {AM}"

  def format_datetime(datetime) do
    day_name =
      datetime
      |> Timex.weekday()
      |> day_name()

    {:ok, formatted_day} = Timex.format(datetime, @format)

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

  def generate_tour_options(_now, number_of_options) when number_of_options < 1,
    do: {:error, :invalid_option}

  def generate_tour_options(now, number_of_options \\ 5) do
    beginning_of_week =
      now
      |> Timex.shift(weeks: 1)
      |> beginning_of_week()

    Enum.reduce(0..(number_of_options - 1), [], &generate_time(&1, &2, beginning_of_week))
  end

  defp generate_time(offset, acc, beginning_of_week) do
    day_of_week = Timex.shift(beginning_of_week, days: offset)

    [Timex.set(day_of_week, hour: 9), Timex.set(day_of_week, hour: 17) | acc]
  end

  defp beginning_of_week(datetime) do
    case Timex.weekday(datetime) do
      1 -> datetime
      _ -> Timex.beginning_of_week(datetime)
    end
  end
end
