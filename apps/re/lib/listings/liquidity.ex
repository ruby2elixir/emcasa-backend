defmodule Re.Listings.Liquidity do
  @moduledoc """
  Module to contain the logic to calculate the liquidity ration
  unding listings details.
  """

  @default_liquidity_radio nil
  @decimal_precision 3

  def calculate(0, _), do: @default_liquidity_radio

  def calculate(_, 0), do: @default_liquidity_radio

  def calculate(_, nil), do: @default_liquidity_radio

  def calculate(nil, _), do: @default_liquidity_radio

  def calculate(price, suggested_price)
      when is_number(price) and
             is_number(suggested_price) do
    # credo:disable-for-lines:2
    ((suggested_price - price) / suggested_price)
    |> Float.round(@decimal_precision)
  end

  def normalize_liquidity_ratio(liquidity_ratio)
      when is_nil(liquidity_ratio) or
             liquidity_ratio <= -1,
      do: 0

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= -0.8,
      do: 1

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= -0.6,
      do: 2

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= -0.4,
      do: 3

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio < -0.2,
      do: 4

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= 0.2,
      do: 5

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= 0.3,
      do: 6

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= 0.4,
      do: 7

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= 0.5,
      do: 8

  def normalize_liquidity_ratio(liquidity_ratio)
      when liquidity_ratio <= 0.6,
      do: 9

  def normalize_liquidity_ratio(_liquidity_ratio), do: 10
end
