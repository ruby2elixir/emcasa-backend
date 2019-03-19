defmodule ReWeb.AbsintheAssertions do
  @moduledoc """
  This module define common assertions for GraphQL response.
  It's used to not duplicate the implementation of default cases (like errors).

  """

  use ExUnit.CaseTemplate

  using do
    quote do
      def assert_forbidden_response(response) do
        [%{"message" => message, "code" => code}] = response["errors"]

        assert 403 == code
        assert "Forbidden" == message
      end

      def assert_unauthorized_response(response) do
        [%{"message" => message, "code" => code}] = response["errors"]

        assert 401 == code
        assert "Unauthorized" == message
      end
    end
  end
end
