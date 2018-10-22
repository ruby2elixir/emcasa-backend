defmodule ReWeb.Exporters.Vivareal.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.Exporters.Vivareal

  def init(args), do: args

  def call(conn, _args) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, Vivareal.export_listings_xml())
  end
end
