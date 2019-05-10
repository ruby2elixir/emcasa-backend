defmodule ReWeb.Resolvers.Accounts do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.Accounts

  alias Re.Accounts.{
    Auth,
    Users
  }

  def account_kit_sign_in(%{access_token: access_token}, _) do
    with {:ok, user} <- Auth.account_kit_sign_in(access_token),
         {:ok, jwt, _full_claims} <- ReWeb.Guardian.encode_and_sign(user) do
      {:ok, %{jwt: jwt, user: user}}
    else
      {:error, %{"message" => message, "code" => code}} ->
        {:error, %{message: message, code: code}}

      error ->
        error
    end
  end

  def favorited(_args, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Users, :favorited_listings, current_user, %{}) do
      :ok -> {:ok, Users.favorited(current_user)}
      error -> error
    end
  end

  def profile(params, %{context: %{current_user: current_user}}) do
    with {:ok, id} <- get_user_id(params, current_user),
         {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :show_profile, current_user, user),
         do: {:ok, user}
  end

  def edit_profile(%{id: id} = params, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :edit_profile, current_user, user),
         do: Users.update(user, params)
  end

  def change_email(%{id: id, email: email}, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :edit_profile, current_user, user),
         {:ok, user} <- Users.change_email(user, email) do
      {:ok, user}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, format_errors(changeset)}
      error -> error
    end
  end

  def change_role(%{uuid: uuid, role: role}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Users, :update_role, current_user),
         {:ok, user} <- Accounts.get_by_uuid(uuid),
         {:ok, user} <- Accounts.change_role(user, role) do
      {:ok, user}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, format_errors(changeset)}
      error -> error
    end
  end

  def owner(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(Re.Accounts, :user, listing)
      |> on_load(fn loader ->
        {:ok, Dataloader.get(loader, Re.Accounts, :user, listing)}
      end)
    else
      {:ok, nil}
    end
  end

  defp is_admin(_, :system), do: true
  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false

  defp format_errors(%{errors: errors}) do
    errors
    |> Enum.map(&format_error/1)
    |> Enum.into(%{})
  end

  defp format_error({type, {message, _}}), do: {:message, "#{type} #{message}"}

  defp get_user_id(%{id: id}, _), do: {:ok, id}
  defp get_user_id(_, %{id: id}), do: {:ok, id}
  defp get_user_id(_, _), do: {:error, :unauthorized}
end
