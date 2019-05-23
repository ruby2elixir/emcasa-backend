defmodule ReWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Re.Repo
      import Ecto

      import Ecto.{
        Changeset,
        Query
      }

      import ReWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint ReWeb.Endpoint

      alias ReWeb.Guardian

      def login_as(conn, user) do
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)

        put_req_header(conn, "authorization", "Token #{jwt}")
      end

      defmacro assert_mapper_match(left, right, key_func) do
        quote do
          assert Enum.sort(unquote(key_func).(unquote(left))) ==
                   Enum.sort(unquote(key_func).(unquote(right)))
        end
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Re.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Re.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
