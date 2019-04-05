defmodule ReWeb.Resolvers.Tags do
  @moduledoc """
  Resolvers for tags.
  """
  alias Re.Tags

  def index(_params, _context) do
    tags = Tags.all()

    {:ok, tags}
  end

  def search(%{name: name}, _context) do
    tags = Tags.search(name)

    {:ok, tags}
  end

  def show(%{uuid: uuid}, _context) do
    Tags.get(uuid)
  end
end
