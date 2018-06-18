defmodule ReWeb.TestEmails do
  @moduledoc false

  def notify_interest(_), do: :ok

  def confirm(_), do: :ok

  def change_email(_), do: :ok

  def welcome(_), do: :ok

  def user_registered(_), do: :ok

  def reset_password(_), do: :ok

  def listing_added(_, _), do: :ok

  def listing_added_admin(_, _), do: :ok

  def listing_updated(_, _, _), do: :ok

  def price_updated(_, _), do: :ok
end
