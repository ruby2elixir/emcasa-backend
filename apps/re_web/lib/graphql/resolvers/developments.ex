defmodule ReWeb.Resolvers.Developments do
  alias Re.{
    Developments
  }

  def index(_params, _context) do
    developments = Developments.all()

    {:ok, developments}
  end

  def show(%{id: id}, _context) do
    Developments.get(id)
  end
end
