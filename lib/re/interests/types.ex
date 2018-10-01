defmodule Re.Interests.Types do
  @moduledoc """
  Context module for interest types
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.InterestType
end
