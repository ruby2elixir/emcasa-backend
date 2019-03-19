defmodule Re.ModelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Re.Repo

      import Ecto

      import Ecto.{
        Changeset,
        Query
      }

      import Re.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Re.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Re.Repo, {:shared, self()})
    end

    :ok
  end
end
