defmodule Re.AlikeTeller do
  @moduledoc """
  Module to interface with aliketeller for related listings
  """

  @spec get(String.t()) :: {:error, :not_found} | {:ok, list(String.t())}
  def get(uuid) do
    case :ets.lookup(:aliketeller, uuid) do
      [] -> {:error, :not_found}
      [{_uuid, uuids}] -> {:ok, uuids}
    end
  end

  def load, do: GenServer.cast(__MODULE__.Server, :load_aliketeller)
end
