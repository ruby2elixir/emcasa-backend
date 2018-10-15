defmodule ReStatistics.ListingVisualization do
  @moduledoc """
  Model to record listing visualizations
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listing_visualizations" do
    field :details, :string

    belongs_to :listing, Re.Listing
    belongs_to :user, Re.User

    timestamps()
  end

  @required ~w(listing_id)a
  @optional ~w(user_id details)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:listing_id)
  end
end
