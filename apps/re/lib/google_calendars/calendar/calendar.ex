defmodule Re.GoogleCalendars.Calendar do
  @moduledoc """
  Schema for storing photographers' calendars
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "calendars" do
    field :external_id, :string
    field :shift_start, :time, default: ~T[08:00:00]
    field :shift_end, :time, default: ~T[18:00:00]

    many_to_many :districts, Re.Addresses.District,
      join_through: Re.GoogleCalendars.CalendarDistrict,
      join_keys: [calendar_uuid: :uuid, district_id: :id],
      on_replace: :delete

    timestamps()
  end

  @required ~w(external_id shift_start shift_end)a
  @optional ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> Re.ChangesetHelper.generate_uuid()
  end

  def changeset_update_districts(struct, districts) do
    struct
    |> change()
    |> put_assoc(:districts, districts)
  end
end
