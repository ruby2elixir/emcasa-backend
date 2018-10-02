defmodule ReIntegrations.Notifications.Emails do
  @moduledoc """
  Wrapper module to call email server
  """

  alias Re.{
    Interest,
    Listing,
    User
  }

  alias ReIntegrations.Notifications.Emails

  def notify_interest(%Interest{} = interest),
    do: GenServer.cast(Emails.Server, {Emails.User, :notify_interest, [interest]})

  def change_email(%User{} = user),
    do: GenServer.cast(Emails.Server, {Emails.User, :change_email, [user]})

  def user_registered(%User{} = user),
    do: GenServer.cast(Emails.Server, {Emails.User, :user_registered, [user]})

  def listing_added_admin(%User{} = user, %Listing{} = listing),
    do: GenServer.cast(Emails.Server, {Emails.User, :listing_added_admin, [user, listing]})

  def listing_updated(%User{} = user, %Listing{} = listing, changes),
    do: GenServer.cast(Emails.Server, {Emails.User, :listing_updated, [user, listing, changes]})

  def monthly_report(user, listings),
    do: GenServer.cast(Emails.Server, {Emails.Report, :monthly_report, [user, listings]})

  def inspect, do: GenServer.call(Emails.Server, :inspect)
end
