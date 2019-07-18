defmodule Re.GoogleCalendars.CalendarDistrict do
  @moduledoc """
  Model that resolve relation between calendars and districts.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  schema "calendar_districts" do
    belongs_to :listing, Re.GoogleCalendars.Calendar,
      type: :binary_id,
      foreign_key: :calendar_uuid,
      references: :uuid,
      primary_key: true

    belongs_to :tag, Re.Addresses.District,
      type: :binary_id,
      foreign_key: :district_uuid,
      references: :uuid,
      primary_key: true
  end

  @required ~w(calendar_uuid district_uuid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
