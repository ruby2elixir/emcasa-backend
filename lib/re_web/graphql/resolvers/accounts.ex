defmodule ReWeb.Resolvers.Accounts do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.Accounts.{
    Auth,
    Users
  }

  def favorited(_args, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Users, :favorited_listings, current_user, %{}) do
      :ok -> {:ok, Users.favorited(current_user)}
      error -> error
    end
  end

  def profile(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Users.get(id),
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

  def change_password(
        %{id: id, new_password: new_password, current_password: current_password},
        %{context: %{current_user: current_user}}
      ) do
    with {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :change_password, current_user, user),
         :ok <- Auth.check_password(current_password, user),
         do: Users.edit_password(user, new_password)
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

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false

  defp format_errors(%{errors: errors}) do
    errors
    |> Enum.map(&format_error/1)
    |> Enum.into(%{})
  end

  defp format_error({type, {message, _}}), do: {:message, "#{type} #{message}"}
end
