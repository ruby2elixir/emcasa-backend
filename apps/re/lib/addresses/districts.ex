defmodule Re.Districts do

  @moduledoc """
  Context for handling districts
  """

  import Ecto.Query

  alias Re.{
    Addresses.District,
    BrokerDistrict,
    Repo
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def districts_by_broker_user(user_uuid) do
    Repo.all(from(
      d in District,
      join: bd in BrokerDistrict,
      where: bd.user_uuid == ^user_uuid,
      select: d
    ))
  end

end
