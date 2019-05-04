defmodule ReWeb.Webhooks.ZapierPlug do
  @moduledoc """
  Plug to handle zapier webhooks
  """
  import Plug.Conn

  require Logger

  @user Application.get_env(:re_integrations, :zapier_webhook_user, "")
  @pass Application.get_env(:re_integrations, :zapier_webhook_pass, "")

  alias ReIntegrations.Zapier

  def init(args), do: args

  def call(%{method: "POST", params: params} = conn, _args) do
    with :ok <- validate_credentials(conn),
         {:ok, _} <- Zapier.new_lead(params) do
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
         [@user, @pass] <- String.split(secret, ":", parts: 2) do
      :ok
    else
      _ -> {:error, :unauthorized}
    end
  end
end
