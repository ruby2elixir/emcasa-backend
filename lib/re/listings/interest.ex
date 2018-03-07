defmodule Re.Listings.Interest do
  @moduledoc """
  Schema module for storing interest in a listing
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "interests" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    belongs_to :listing, Re.Listing
    belongs_to :interest_type, Re.Listings.InterestType

    timestamps()
  end

  @required ~w(name email listing_id)a
  @optional ~w(phone message interest_type_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
