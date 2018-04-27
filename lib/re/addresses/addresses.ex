defmodule Re.Addresses do
  @moduledoc """
  Context for handling addresses
  """

  alias Re.{
    Address,
    Repo
  }

  def get(params) do
    case Repo.get_by(
           Address,
           street: params["street"] || "",
           postal_code: params["postal_code"] || "",
           street_number: params["street_number"] || ""
         ) do
      nil -> {:error, :not_found}
      address -> {:ok, address}
    end
  end

  def insert_or_update(params) do
    changeset =
      params
      |> get()
      |> build_address(params)
      |> Address.changeset(params)

    case Repo.insert_or_update(changeset) do
      {:ok, address} -> {:ok, address, changeset}
      error -> error
    end
  end

  defp build_address({:error, :not_found}, %{
         "street" => street,
         "postal_code" => postal_code,
         "street_number" => street_number
       }) do
    %Address{street: street, postal_code: postal_code, street_number: street_number}
  end

  defp build_address({:ok, address}, _), do: address
end
