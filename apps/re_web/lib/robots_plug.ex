defmodule ReWeb.RobotsPlug do
  @moduledoc """
  Plug to serve robots.txt
  """
  import Plug.Conn

  def init(args), do: args

  def call(conn, _args) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, """
    User-agent: *
    Disallow: /*
    """)
  end
end
