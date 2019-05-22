defmodule ReIntegrations.PriceTeller.Input do
  @moduledoc """
  Module for grouping credipronto simulator query input params
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "priceteller_input" do
    field :type, :string
    field :zip_code, :string
    field :street_number, :string
    field :area, :integer
    field :bathrooms, :integer
    field :bedrooms, :integer
    field :suites, :integer
    field :parking, :integer
    field :condo_fee, :integer
    field :lat, :float
    field :lng, :float
  end

  @params ~w(type zip_code street_number area bathrooms bedrooms suites parking condo_fee
             lat lng)a

  @types ~w(APARTMENT CONDOMINIUM KITNET HOME TWO_STORY_HOUSE FLAT PENTHOUSE)

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset.changes}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  defp changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@params)
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
    |> validate_length(:zip_code, is: 8)
    |> validate_number(:area, greater_than: 15, less_than: 600)
    |> validate_number(:bathrooms, greater_than: 0, less_than: 20)
    |> validate_number(:bedrooms, greater_than: 0, less_than: 20)
    |> validate_number(:suites, greater_than: 0, less_than: 20)
    |> validate_number(:parking, greater_than: 0, less_than: 20)
    |> validate_number(:condo_fee, greater_than: 0, less_than: 10_000)
  end
end
