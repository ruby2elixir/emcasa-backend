defmodule Re.PriceSuggestions.Factors do
  @moduledoc """
  Schema for storing price suggestion factors
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "price_suggestion_factors" do
    field :street, :string
    field :intercept, :float
    field :area, :float
    field :bathrooms, :float
    field :rooms, :float
    field :garage_spots, :float
    field :r2, :float

    timestamps()
  end

  @attrs ~w(street intercept area bathrooms rooms garage_spots r2)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs)
    |> validate_required(@attrs)
  end
end
