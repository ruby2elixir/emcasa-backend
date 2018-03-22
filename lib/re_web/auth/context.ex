defmodule ReWeb.Auth.Context do
  @behaviour Plug

  import Plug.Conn

  alias Re.{Repo, User}

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Token " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{current_user: nil}
    end
  end

  defp authorize(token) do
    token
    |> ReWeb.Guardian.resource_from_token()
    |> case do
      {:ok, user, _claims} -> {:ok, user}
      _error -> {:error, "invalid authorization token"}
    end
  end
end
