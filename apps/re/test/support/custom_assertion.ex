defmodule Re.CustomAssertion do
  @moduledoc """
  Module for defining custom test assertions
  """

  @doc """
  Function to check a list of things accoring to a mapper function
  Ex: map_id = fn items -> Enum.map(items, & &1.id)
  assert_mapper_match(expected, actual, map_id)
  """
  defmacro assert_mapper_match(left, right, key_func) do
    quote do
      assert Enum.sort(unquote(key_func).(unquote(left))) ==
               Enum.sort(unquote(key_func).(unquote(right)))
    end
  end
end
