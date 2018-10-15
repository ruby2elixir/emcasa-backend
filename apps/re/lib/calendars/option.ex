defmodule Re.Calendars.Option do
  @moduledoc """
  Embedded schema for tour appointment with datetime option
  """
  use Ecto.Schema

  embedded_schema do
    field :datetime, :naive_datetime
  end

  def changeset(struct, params \\ %{}), do: Ecto.Changeset.cast(struct, params, ~w(datetime)a)
end
