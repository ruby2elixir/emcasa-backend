defmodule ReWeb.Exporters.Zap.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  require Logger

  alias Re.Exporters.Zap

  def init(args), do: args

  def call(conn, _args) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, Zap.export_listings_xml())
  end
end
