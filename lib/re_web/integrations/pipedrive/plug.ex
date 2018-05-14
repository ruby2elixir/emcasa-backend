defmodule ReWeb.Integrations.Pipedrive.Plug do
  import Plug.Conn

  @pipedrive Application.get_env(:re, :pipedrive, ReWeb.Integrations.Pipedrive)

  @user Application.get_env(:re, :pipedrive_webhook_user, "")
  @pass Application.get_env(:re, :pipedrive_webhook_pass, "")

  def init(args), do: args

  def call(%{method: "POST", params: params} = conn, _args) do
    case {get_req_header(conn, "php-auth-user"), get_req_header(conn, "php-auth-pw")} do
      {[user], [pass]} when user == @user and pass == @pass ->
        @pipedrive.handle_webhook(params)

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "ok")
      _ ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(403, "Unauthorized")
    end
  end
end
