defmodule Re.Listings.PriceHistory do
  @moduledoc """
  Model for listings's price history
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "price_histories" do
    field :price, :integer

    belongs_to :listing, Re.Listing

    timestamps()
  end

  @attributes ~w(price listing_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_required(@attributes)
  end
end
