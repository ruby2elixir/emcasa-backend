defmodule Re.PriceTeller.Output do
  @moduledoc """
  Module for validating priceteller output payload
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "priceteller_output" do
    field :listing_price, :float
    field :listing_price_rounded, :float
    field :sale_price, :float
    field :sale_price_rounded, :float
    field :listing_price_error_q90_min, :float
    field :listing_price_error_q90_max, :float
    field :listing_price_per_sqr_meter, :float
    field :listing_average_price_per_sqr_meter, :float
  end

  @params ~w(listing_price listing_price_rounded sale_price sale_price_rounded
             listing_price_error_q90_min listing_price_error_q90_max listing_price_per_sqr_meter
             listing_average_price_per_sqr_meter)a

  def validate(payload) do
    %__MODULE__{}
    |> changeset(payload)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset.changes}
      changeset -> {:error, :invalid_output, payload, changeset}
    end
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
