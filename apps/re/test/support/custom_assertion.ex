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

  @doc """
  Function to check if a job was enqueued.
    ## Options

    * `:count` - Number of jobs of a given type, default is 1.
  """
  defmacro assert_enqueued_job(enqueued_jobs, expected_job_name, count \\ 1) do
    quote do
      expected_jobs =
        Enum.filter(unquote(enqueued_jobs), fn %{params: %{"type" => job_type}} ->
          job_type == unquote(expected_job_name)
        end)

      assert Enum.count(expected_jobs) == unquote(count)
    end
  end
end
