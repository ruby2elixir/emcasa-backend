defmodule ReIntegrations.PriceTeller.Output do
  @moduledoc """
  Module for grouping credipronto simulator query input params
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "priceteller_output" do
    field :listing_price, :float
    field :listing_price_rounded, :float
    field :sale_price, :float
    field :sale_price_rounded, :float
  end

  @params ~w(listing_price listing_price_rounded sale_price sale_price_rounded)a

  def validate(%{"output" => output}) do
    %__MODULE__{}
    |> changeset(output)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset.changes}
      changeset -> {:error, :invalid_output, output, changeset}
    end
  end

  def validate(payload), do: {:error, :invalid_output, payload}

  defp changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
