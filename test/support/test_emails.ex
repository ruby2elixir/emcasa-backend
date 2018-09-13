defmodule ReWeb.TestEmails do
  @moduledoc false

  def notify_interest(_), do: :ok

  def change_email(_), do: :ok

  def user_registered(_), do: :ok

  def listing_added_admin(_, _), do: :ok

  def listing_updated(_, _, _), do: :ok
end
