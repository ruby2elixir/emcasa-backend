defmodule Re.Accounts do
  alias Re.{
    Accounts.DataloaderQueries,
    Repo
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(User, args), do: DataloaderQueries.build(User, args)

  def query(query, _args), do: query
end
