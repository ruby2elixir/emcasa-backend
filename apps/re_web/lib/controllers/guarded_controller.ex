defmodule ReWeb.GuardedController do
  @moduledoc """
  Module to inject user as a third argument in controller action
  """

  defmacro __using__(_opts \\ []) do
    quote do
      alias ReWeb.Guardian.Plug

      def action(conn, _opts) do
        apply(__MODULE__, action_name(conn), [
          conn,
          conn.params,
          Plug.current_resource(conn)
        ])
      end
    end
  end
end
