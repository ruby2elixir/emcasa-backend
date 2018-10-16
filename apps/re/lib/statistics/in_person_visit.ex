defmodule Re.Statistics.InPersonVisit do
  @moduledoc """
  Model to record in person visits
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "in_person_visits" do
    field :date, :utc_datetime

    belongs_to :listing, Re.Listing

    timestamps()
  end

  @required ~w(date listing_id)a
  @optional ~w()a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:listing_id, message: "does not exist")
  end
end
