defmodule Re.SellerLeads.Policy do
  @moduledoc """
  Policy module for user permission on seller leads
  """

  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(:create_seller_lead, %User{role: "user"}, _), do: :ok

  def authorize(:create_broker_seller_lead, %User{role: "user", type: "partner_broker"}, _),
    do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
