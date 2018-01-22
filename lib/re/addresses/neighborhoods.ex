defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{
    Address,
    Listing,
    Repo
  }

  @all_query from(
               a in Address,
               join: l in Listing,
               where: l.address_id == a.id and l.is_active,
               select: a.neighborhood,
               distinct: a.neighborhood
             )

  def all do
    Repo.all(@all_query)
  end
end
