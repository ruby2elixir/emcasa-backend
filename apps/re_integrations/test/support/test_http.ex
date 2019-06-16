defmodule ReIntegrations.TestHTTP do
  @moduledoc false

  def get("https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename),
    do: {:ok, %{body: filename}}

  def get(%URI{path: "/buildings/1/typologies/1/units"}, _) do
    {:ok, %{body: %{"units" => []}}}
  end

  def get(%URI{path: "/buildings/1/typologies/2/units"}, _) do
    {:ok, %{body: %{"units" => []}}}
  end

  def get(%URI{path: "/simulator"}, [], _opts),
    do: {:ok, %{body: "{\"cem\":\"10,8%\",\"cet\":\"11,3%\"}"}}

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
