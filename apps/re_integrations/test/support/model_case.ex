defmodule ReIntegrations.ModelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ReIntegrations.Repo

      import Ecto

      import Ecto.{
        Changeset,
        Query
      }

      import ReIntegrations.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ReIntegrations.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ReIntegrations.Repo, {:shared, self()})
    end

    :ok
  end
end
