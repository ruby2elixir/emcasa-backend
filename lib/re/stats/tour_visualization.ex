defmodule Re.Stats.TourVisualization do
  @moduledoc """
  Model to record tour visualizations
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "tour_visualizations" do
    field :details, :string
    field :matterport_code, :string

    belongs_to :listing, Re.Listing
    belongs_to :user, Re.User

    timestamps()
  end

  @required ~w(listing_id matterport_code)a
  @optional ~w(user_id details)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
