defmodule ReWeb.Webhooks.GrupozapPlug do
  @moduledoc """
  Plug to handle grupozap webhooks
  Documentation following: https://github.com/grupozap/crm-lead-integration/tree/0ff030871091fefd9a6160e7f0f72315d1c5f0f9
  """
  import Plug.Conn

  require Logger

  @secret Application.get_env(:re_integrations, :grupozap_webhook_secret, "")

  alias ReIntegrations.Grupozap

  def init(args), do: args

  def call(%{method: "POST", params: params} = conn, _args) do
    with :ok <- validate_credentials(conn),
         {:ok, _} <- Grupozap.new_buyer_lead(params) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "ok")
    else
      {:error, :unauthorized} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(401, "Unauthorized")

      error ->
        Logger.error("Unexpected return: #{Kernel.inspect(error)}")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(422, "Unprocessable Entity")
    end
  end

  def call(%{method: method} = conn, _args) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(405, "#{method} not allowed")
  end

  defp validate_credentials(conn) do
    with ["Basic " <> token] <- get_req_header(conn, "authorization"),
         {:ok, secret} <- Base.decode64(token),
         ["vivareal", @secret] <- String.split(secret, ":", parts: 2) do
      :ok
    else
      _ -> {:error, :unauthorized}
    end
  end
end
