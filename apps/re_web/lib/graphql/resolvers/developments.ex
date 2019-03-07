defmodule ReWeb.Resolvers.Developments do
  alias Re.{
    Addresses,
    Developments
  }

  def index(_params, _context) do
    developments = Developments.all()

    {:ok, developments}
  end

  def show(%{id: id}, _context) do
    Developments.get(id)
  end

  def insert(%{input: development_params}, %{context: %{current_user: current_user}}) do
    with :ok <-
           Bodyguard.permit(Developments, :insert_development, current_user, development_params),
         {:ok, address} <- get_address(development_params),
         {:ok, development} <- Developments.insert(development_params, address) do
      {:ok, development}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  def update(%{id: id, input: development_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, development} <- Developments.get(id),
         :ok <- Bodyguard.permit(Developments, :update_development, current_user, development),
         {:ok, address} <- get_address(development_params),
         {:ok, development} <- Developments.update(development, development_params, address) do
      {:ok, development}
    end
  end

  defp get_address(%{address: address_params}), do: Addresses.insert_or_update(address_params)
  defp get_address(%{address_id: id}), do: Addresses.get_by_id(id)
  defp get_address(_), do: {:error, :bad_request}
end
