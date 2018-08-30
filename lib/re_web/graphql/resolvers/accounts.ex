defmodule ReWeb.Resolvers.Accounts do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.Accounts.{
    Auth,
    Users
  }

  def sign_in(%{email: email, password: password}, _) do
    with {:ok, user} <- Auth.find_user(email),
         :ok <- Auth.check_password(password, user),
         {:ok, jwt, _full_claims} <- ReWeb.Guardian.encode_and_sign(user) do
      {:ok, %{jwt: jwt, user: user}}
    end
  end

  def account_kit_sign_in(%{auth_code: auth_code}, _) do
    response = AccountKit.access_token(auth_code)
  end

  def register(params, _) do
    with {:ok, user} <- Users.create(params),
         {:ok, jwt, _full_claims} <- ReWeb.Guardian.encode_and_sign(user) do
      {:ok, %{jwt: jwt, user: user}}
    end
  end

  def confirm(%{token: token}, _) do
    with {:ok, user} <- Users.confirm(token),
         {:ok, jwt, _full_claims} <- ReWeb.Guardian.encode_and_sign(user) do
      {:ok, %{jwt: jwt, user: user}}
    end
  end

  def reset_password(%{email: email}, _) do
    with {:ok, user} <- Users.get_by_email(email),
         {:ok, user} <- Users.reset_password(user) do
      {:ok, user}
    end
  end

  def redefine_password(%{reset_token: reset_token, new_password: new_password}, _) do
    with {:ok, user} <- Users.get_by_reset_token(reset_token),
         {:ok, user} <- Users.redefine_password(user, new_password) do
      {:ok, user}
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
