defmodule ReIntegrations.Search do
  @moduledoc """
  Module to perform operations with elasticsearch
  """
  @spec build_index() :: GenServer.cast()
  def build_index(), do: GenServer.cast(__MODULE__.Server, :build_index)

  @spec cleanup_index() :: GenServer.cast()
  def cleanup_index(), do: GenServer.cast(__MODULE__.Server, :cleanup_index)
end
