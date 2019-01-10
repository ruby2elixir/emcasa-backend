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

  def call(conn, _args) do
    xml_listings =
      Listings.exportable()
      |> Zap.export_listings_xml()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml_listings)
  end
end
