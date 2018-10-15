defmodule Re.PriceSuggestions.Request do
  @moduledoc """
  Schema for storing price suggestion request
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "price_suggestion_requests" do
    field :name, :string
    field :email, :string

    field :area, :integer
    field :rooms, :integer
    field :bathrooms, :integer
    field :garage_spots, :integer
    field :is_covered, :boolean

    belongs_to :address, Re.Address
    belongs_to :user, Re.User

    timestamps()
  end

  @required ~w(address_id area rooms bathrooms garage_spots is_covered)a
  @optional ~w(name email user_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
