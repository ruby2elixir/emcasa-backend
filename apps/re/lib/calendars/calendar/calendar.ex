defmodule Re.Calendars.Calendar do
  @moduledoc """
  Schema for storing photographers' calendars
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "calendars" do
    field :external_id, :string
    field :name, :string
    field :speed, :string
    field :shift_start, :time, default: ~T[08:00:00]
    field :shift_end, :time, default: ~T[18:00:00]

    many_to_many :districts, Re.Addresses.District,
      join_through: Re.Calendars.CalendarDistrict,
      join_keys: [calendar_uuid: :uuid, district_uuid: :uuid],
      on_replace: :delete

    belongs_to :address, Re.Address,
      type: Ecto.UUID,
      foreign_key: :address_uuid,
      references: :uuid

    timestamps()
  end

  @speed_types ["fast", "normal", "slow", "very slow", "bike"]

  @required ~w(name speed address_uuid shift_start shift_end)a
  @optional ~w(external_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:speed, @speed_types)
    |> Re.ChangesetHelper.generate_uuid()
  end

  def changeset_update_districts(struct, districts) do
    struct
    |> change()
    |> put_assoc(:districts, districts)
  end
end
