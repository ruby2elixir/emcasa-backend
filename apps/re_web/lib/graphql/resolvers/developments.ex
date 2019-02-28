defmodule ReWeb.Resolvers.Developments do

  alias Re.{
    Developments
  }

  def index(_params, _context) do
    developments = Developments.all()

    {:ok, developments}
  end

  def show(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, development} <- Developments.get(id),
         #  :ok <- Bodyguard.permit(Listings, :show_listing, current_user, listing) do
         :ok <- :ok do
      {:ok, development}
    end
  end
end
