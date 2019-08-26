defmodule ReIntegrations.TestHTTP do
  @moduledoc false

  def post(%URI{path: "/priceteller"}, _, [
        {"Content-Type", "application/json"},
        {"X-Api-Key", "mahtoken"}
      ]),
      do:
        {:ok,
         %{
           body:
             "{" <>
               "\"listing_price\":632868.63," <>
               "\"listing_price_rounded\":635000.0," <>
               "\"sale_price\":575910.45," <>
               "\"sale_price_rounded\":575000.0}"
         }}
end
