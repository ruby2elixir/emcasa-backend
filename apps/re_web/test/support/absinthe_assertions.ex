defmodule ReWeb.AbsintheAssertions do
  @moduledoc """
  This module define common assertions for GraphQL response.
  It's used to not duplicate the implementation of default cases (like errors).

  """

  use ExUnit.CaseTemplate

  using do
    quote do
      def assert_forbidden_response(response) do
        error = response["errors"]
          |> List.first()

        assert 403 == error["code"]
        assert "Forbidden" == error["message"]
      end

      def assert_unauthorized_response(response) do
        error = response["errors"]
          |> List.first()

        assert 401 == error["code"]
        assert "Unauthorized" == error["message"]
      end
    end
  end
end
