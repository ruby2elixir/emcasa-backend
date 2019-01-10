defmodule ReWeb.Exporters.Zap.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Zap,
    Listings
  }

  def init(args), do: args

  def call(%Plug.Conn{path_info: [state_slug, city_slug]} = conn, _args) do
    xml_listings =
      Listings.exportable(%{state_slug: state_slug, city_slug: city_slug})
      |> Zap.export_listings_xml()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml_listings)
  end
end
