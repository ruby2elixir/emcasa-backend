defmodule ReWeb.Integrations.Pipedrive.Plug do
  import Plug.Conn

  def init(args), do: args

  def call(%{method: "POST", params: params} = conn, _args) do
    IO.inspect conn
    # Pipedrive.handle_webhook(params)

    send_resp(conn, 200, "ok")
  end
end
