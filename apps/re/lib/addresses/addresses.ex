defmodule Re.Addresses do
  @moduledoc """
  Context for handling addresses
  """

  import Ecto.Query

  alias Re.{
    Address,
    Repo
  }

  alias __MODULE__.Neighborhoods

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, %{has_admin_rights: true}), do: query

  def query(query, _), do: from(a in query, select_merge: %{street_number: nil})

  def get(params) do
    case Repo.get_by(
           Address,
           street: Map.get(params, "street") || Map.get(params, :street, ""),
           postal_code: Map.get(params, "postal_code") || Map.get(params, :postal_code, ""),
           street_number: Map.get(params, "street_number") || Map.get(params, :street_number, "")
         ) do
      nil -> {:error, :not_found}
      address -> {:ok, address}
    end
  end

  def get_by_id(id) do
    case Repo.get(Address, id) do
      nil -> {:error, :not_found}
      address -> {:ok, address}
    end
  end

  def insert_or_update(params) do
    params = normalize_params(params)

    params
    |> get()
    |> build_address(params)
    |> Address.changeset(params)
    |> Repo.insert_or_update()
  end

  def is_covered(address), do: Neighborhoods.is_covered(address)

  defp build_address({:error, :not_found}, %{
         "street" => street,
         "postal_code" => postal_code,
         "street_number" => street_number
       }) do
    %Address{street: street, postal_code: postal_code, street_number: street_number}
  end

  defp build_address({:error, :not_found}, %{
         street: street,
         postal_code: postal_code,
         street_number: street_number
       }) do
    %Address{street: street, postal_code: postal_code, street_number: street_number}
  end

  defp build_address({:ok, address}, _), do: address

  defp normalize_params(params) do
    params
    |> pad_trailing_postal_code_with_zero()
  end

  defp pad_trailing_postal_code_with_zero(%{"postal_code" => postal_code} = params) do
    new_postal_code = fill_postal_code(postal_code)

    params
    |> Map.merge(%{"postal_code" => new_postal_code})
  end

  defp pad_trailing_postal_code_with_zero(%{postal_code: postal_code} = params) do
    new_postal_code = fill_postal_code(postal_code)

    params
    |> Map.merge(%{postal_code: new_postal_code})
  end

  defp pad_trailing_postal_code_with_zero(params), do: params

  defp fill_postal_code(postal_code)
       when not is_nil(postal_code) and is_bitstring(postal_code) and byte_size(postal_code) == 5 do
    postal_code <> "-000"
  end

  defp fill_postal_code(postal_code), do: postal_code
end
