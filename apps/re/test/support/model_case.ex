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

    :ok
  end
end
