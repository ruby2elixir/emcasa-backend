defmodule Re.Addresses.District do
  @moduledoc """
  Model for districts.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.Slugs

  schema "districts" do
    field(:uuid, Ecto.UUID)
    field(:state, :string)
    field(:city, :string)
    field(:name, :string)
    field(:state_slug, :string)
    field(:city_slug, :string)
    field(:name_slug, :string)
    field(:description, :string, default: "")
    field(:status, :string, default: "uncovered")
    field(:sort_order, :integer)

    many_to_many(:calendars, Re.Calendars.Calendar,
      join_through: Re.Calendars.CalendarDistrict,
      join_keys: [district_uuid: :uuid, calendar_uuid: :uuid],
      on_replace: :delete
    )

    many_to_many(:users, Re.User,
      join_through: Re.BrokerDistrict,
      join_keys: [district_uuid: :uuid, user_uuid: :uuid],
      on_replace: :delete
    )

    timestamps()
  end

  @required ~w(state city name)a
  @optional ~w(status description sort_order)a
  @params @required ++ @optional

  @sluggified_attr ~w(state city name)a

  @statuses ~w(covered partially_covered uncovered)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_length(:name, max: 128)
    |> validate_length(:city, max: 128)
    |> validate_length(:state, is: 2)
    |> unique_constraint(:neighborhood, name: :neighborhood)
    |> validate_inclusion(:status, @statuses)
    |> generate_slugs()
    |> Re.ChangesetHelper.generate_uuid()
  end

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Slugs.generate_slug(&1, &2))
  end
end
