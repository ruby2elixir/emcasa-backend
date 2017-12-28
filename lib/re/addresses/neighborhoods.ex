defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.Address

  def all do
    Repo.all(from a in Address, select: a.neighborhood)
  end
end
