defmodule Re.Listings.Liquidity do
  @moduledoc """
  Module to contain the logic to calculate the liquidity ration
  unding listings details.
  """

  @default_liquidity_radio nil

  def calculate(0, _), do: @default_liquidity_radio

  def calculate(_, 0), do: @default_liquidity_radio

  def calculate(_, nil), do: @default_liquidity_radio

  def calculate(price, suggested_price)
      when is_number(price) and
             is_number(suggested_price) do
    (suggested_price - price) / suggested_price
  end
end
