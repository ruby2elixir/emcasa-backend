defmodule ReIntegrations.ModelCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

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
    :ok = Sandbox.checkout(Re.Repo)
    :ok = Sandbox.checkout(ReIntegrations.Repo)

    unless tags[:async] do
      Sandbox.mode(ReIntegrations.Repo, {:shared, self()})
      Sandbox.mode(Re.Repo, {:shared, self()})
    end

    :ok
  end
end
