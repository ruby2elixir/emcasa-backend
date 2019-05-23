defmodule Re.CustomAssertion do
  defmacro assert_mapper_match(left, right, key_func) do
    quote do
      assert Enum.sort(unquote(key_func).(unquote(left))) ==
               Enum.sort(unquote(key_func).(unquote(right)))
    end
  end
end
