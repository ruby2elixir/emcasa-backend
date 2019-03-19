defmodule Re.Listings.StatusHistory do
  @moduledoc """
  Model for listings's status history
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "status_histories" do
    field :status, :string

    belongs_to :listing, Re.Listing

    timestamps()
  end

  @attributes ~w(status listing_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_required(@attributes)
  end
end
