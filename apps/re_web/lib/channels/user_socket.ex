defmodule ReWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: ReWeb.Schema

  def connect(params, socket) do
    socket = Absinthe.Phoenix.Socket.put_options(socket, context: build_context(params))

    {:ok, socket}
  end

  def build_context(params) do
    with "Token " <> token <- Map.get(params, "Authorization"),
         {:ok, current_user, _claims} <- ReWeb.Guardian.resource_from_token(token) do
      %{current_user: current_user}
    else
      _ -> %{current_user: nil}
    end
  end

  def id(_socket), do: nil
end
