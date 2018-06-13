defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """
  alias __MODULE__.DataloaderQueries

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(User, args), do: DataloaderQueries.build(User, args)

  def query(query, _args), do: query
end
