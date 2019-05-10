defmodule ReWeb.HealthChecks do
  @moduledoc """
  YndPhxBootstrapWeb.HealthChecks is responsible for checking of the health of the app.
  """
  alias Ecto.Adapters.SQL
  alias Re.Repo

  def check_repo do
    case SQL.query!(Repo, "SELECT 1") do
      %{num_rows: 1, rows: [[1]]} -> :ok
      error -> {:error, "#{Kernel.inspect(error)}"}
    end
  end
end
