defmodule ReWeb.Integrations.Pipedrive.Plug do
  import Plug.Conn

  @user Application.get_env(:re, :pipedrive_webhook_user, "")
  @pass Application.get_env(:re, :pipedrive_webhook_pass, "")

  alias ReWeb.Integrations.Pipedrive

  def init(args), do: args

  def call(%{method: "POST", params: params} = conn, _args) do
    with :ok <- validate_credentials(conn),
         :ok <- Pipedrive.validate_payload(params) do
      Pipedrive.handle_webhook(params)

      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "ok")
    else
      {:error, :not_authorized} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(403, "Unauthorized")

      {:error, :not_handled} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(422, "Webhook not handled")
    end
  end

  def call(%{method: method} = conn, _args), do: send_resp(conn, 405, "#{method} not allowed")

  defp validate_credentials(conn) do
    case {get_req_header(conn, "php-auth-user"), get_req_header(conn, "php-auth-pw")} do
      {[user], [pass]} when user == @user and pass == @pass -> :ok
      _ -> {:error, :not_authorized}
    end
  end
end
