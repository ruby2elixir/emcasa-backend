defmodule ReWeb.Graphql.SchemaHelpers do
  @moduledoc """
  Module for absinthe helper functions
  """

  @spec parse_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  def parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> :error
    end
  end

  def parse_datetime(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}

  def parse_datetime(_), do: :error
end
