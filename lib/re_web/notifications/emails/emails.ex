defmodule ReWeb.Notifications.Emails do
  @moduledoc """
  Wrapper module to call email server
  """

  alias Re.{
    Interest,
    Listing,
    User
  }

  alias ReWeb.Notifications.{
    Emails.Server,
    ReportEmail,
    UserEmail
  }

  def notify_interest(%Interest{} = interest),
    do: GenServer.cast(Server, {UserEmail, :notify_interest, [interest]})

  def confirm(%User{} = user), do: GenServer.cast(Server, {UserEmail, :confirm, [user]})

  def change_email(%User{} = user), do: GenServer.cast(Server, {UserEmail, :change_email, [user]})

  def welcome(%User{} = user), do: GenServer.cast(Server, {UserEmail, :welcome, [user]})

  def user_registered(%User{} = user),
    do: GenServer.cast(Server, {UserEmail, :user_registered, [user]})

  def reset_password(%User{} = user),
    do: GenServer.cast(Server, {UserEmail, :reset_password, [user]})

  def listing_added(%User{} = user, %Listing{} = listing),
    do: GenServer.cast(Server, {UserEmail, :listing_added, user, listing})

  def listing_added_admin(%User{} = user, %Listing{} = listing),
    do: GenServer.cast(Server, {UserEmail, :listing_added_admin, [user, listing]})

  def listing_updated(%User{} = user, %Listing{} = listing, changes),
    do: GenServer.cast(Server, {UserEmail, :listing_updated, [user, listing, changes]})

  def price_updated(new_price, listing),
    do: GenServer.cast(Server, {UserEmail, :price_updated, new_price, listing})

  def monthly_report(user, listings),
    do: GenServer.cast(Server, {ReportEmail, :monthly_report, [user, listings]})

  def inspect, do: GenServer.call(Server, :inspect)
end
