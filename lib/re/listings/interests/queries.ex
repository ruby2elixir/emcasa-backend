defmodule Re.Listings.Interests.Queries do
  @moduledoc """
  Module for grouping listing queries
  """

  alias Re.Listings.Interest

  import Ecto.Query

  def with_type(query \\ Interest), do: from(i in query, where: not is_nil(i.interest_type_id))
  # def with_type(query \\ Interest), do: where(query, [i], not is_nil(i.interest_type_id))
end
