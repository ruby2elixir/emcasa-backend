defmodule ReIntegrations.Credipronto.Mapper do
  @moduledoc """
  Module for mapping Credipronto's query and response payloads
  """

  def query_out(params), do: Enum.reduce(params, %{}, &map_attributes/2)

  def payload_in(params), do: Enum.reduce(params, %{}, &map_payload/2)

  defp map_attributes({:mutuary, value}, acc), do: Map.put(acc, :mutuario, value)

  defp map_attributes({:birthday, value}, acc), do: Map.put(acc, :data_nascimento, encode_date(value))

  defp map_attributes({:include_coparticipant, value}, acc), do: Map.put(acc, :incluir_co, encode_boolean(value))

  defp map_attributes({:net_income, value}, acc), do: Map.put(acc, :renda_liquida, encode_decimal(value))

  defp map_attributes({:amortization, value}, acc), do: Map.put(acc, :amortizacao, encode_boolean(value))

  defp map_attributes({:annual_interest, value}, acc), do: Map.put(acc, :juros_anual, encode_float(value))

  defp map_attributes({:birthday_coparticipant, value}, acc), do: Map.put(acc, :data_nascimento_co, encode_date(value))

  defp map_attributes({:calculate_tr, value}, acc), do: Map.put(acc, :calcular_tr, encode_boolean(value))

  defp map_attributes({:evaluation_rate, value}, acc), do: Map.put(acc, :tarifa_avaliacao, encode_decimal(value))

  defp map_attributes({:fundable_value, value}, acc), do: Map.put(acc, :valor_financiavel, encode_decimal(value))

  defp map_attributes({:home_equity_annual_interest, value}, acc), do: Map.put(acc, :juros_anual_home_equity, encode_float(value))

  defp map_attributes({:insurer, value}, acc), do: Map.put(acc, :seguradora, value)

  defp map_attributes({:itbi_value, value}, acc), do: Map.put(acc, :valor_itbi, encode_decimal(value))

  defp map_attributes({:listing_price, value}, acc), do: Map.put(acc, :valor_imovel, encode_decimal(value))

  defp map_attributes({:listing_type, value}, acc), do: Map.put(acc, :tipo_imovel, value)

  defp map_attributes({:net_income_coparticipant, value}, acc), do: Map.put(acc, :renda_liquida_co, encode_decimal(value))

  defp map_attributes({:product_type, value}, acc), do: Map.put(acc, :tipo_produto, value)

  defp map_attributes({:rating, value}, acc), do: Map.put(acc, :rating, to_string(value))

  defp map_attributes({:sum, value}, acc), do: Map.put(acc, :somar, encode_boolean(value))

  defp map_attributes({:term, value}, acc), do: Map.put(acc, :prazo, to_string(value))

  defp encode_date(nil), do: ""

  defp encode_date(%Date{} = date) do
    day = date.day
      |> to_string()
      |> String.pad_leading(2, "0")

    month = date.month
      |> to_string()
      |> String.pad_leading(2, "0")

    year = date.year
      |> to_string()
      |> String.pad_leading(2, "0")

    "#{day}/#{month}/#{year}"
  end

  defp encode_boolean(true), do: "S"
  defp encode_boolean(_), do: "N"

  defp encode_decimal(nil), do: ""

  defp encode_decimal(%Decimal{} = decimal) do
    decimal
    |> Decimal.round(2)
    |> Decimal.mult(100)
    |> Decimal.to_integer()
    |> CurrencyFormatter.format("BRL", keep_decimals: true)
    |> trim_currency()
  end

  defp encode_float(float), do: :erlang.float_to_binary(float, [decimals: 10])

  defp trim_currency("R$" <> rest), do: rest

  defp map_payload({"cem", value}, acc), do: Map.put(acc, :cem, value)

  defp map_payload({"cet", value}, acc), do: Map.put(acc, :cet, value)

  defp map_payload({_key, _value}, acc), do: acc
end
