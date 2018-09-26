defmodule Re.Calendars.TourAppointment do
  @moduledoc """
  Schema for storing tour appointments
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "tour_appointments" do
    field :wants_pictures, :boolean
    field :wants_tour, :boolean

    embeds_many(:options, Re.Calendars.Option)

    belongs_to :user, Re.User
    belongs_to :listing, Re.Listing

    timestamps()
  end

  @required ~w(wants_pictures wants_tour user_id listing_id)a
  @optional ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> cast_embed(
      :options,
      with: &Re.Calendars.Option.changeset/2
    )
    |> validate_required(@required)
  end
end
