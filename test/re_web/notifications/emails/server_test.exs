defmodule ReWeb.Notifications.Emails.ServerTest do
  use Re.ModelCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Listing,
    Repo
  }

  alias ReWeb.Notifications.{
    Emails.Server,
    UserEmail
  }

  describe "handle_cast/2" do
    test "notify_interest/1" do
      interest = insert(:interest, interest_type: build(:interest_type))
      Server.handle_cast({UserEmail, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      assert_email_sent(UserEmail.notify_interest(interest))
    end

    test "confirm/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :confirm, [user]}, [])
      assert_email_sent(UserEmail.confirm(user))
    end

    test "change_email/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :change_email, [user]}, [])
      assert_email_sent(UserEmail.change_email(user))
    end

    test "welcome/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :welcome, [user]}, [])
      assert_email_sent(UserEmail.welcome(user))
    end

    test "user_registered/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :user_registered, [user]}, [])
      assert_email_sent(UserEmail.user_registered(user))
    end

    test "reset_password/1" do
      user = insert(:user, reset_token: UUID.uuid4())
      Server.handle_cast({UserEmail, :reset_password, [user]}, [])
      assert_email_sent(UserEmail.reset_password(user))
    end

    test "listing_added/2" do
      user = insert(:user)
      listing = insert(:listing)
      Server.handle_cast({UserEmail, :listing_added, [user, listing]}, [])
      assert_email_sent(UserEmail.listing_added(user, listing))
    end

    test "listing_added_admin/2" do
      user = insert(:user)
      listing = insert(:listing)
      Server.handle_cast({UserEmail, :listing_added_admin, [user, listing]}, [])
      assert_email_sent(UserEmail.listing_added_admin(user, listing))
    end

    test "listing_updated/2" do
      user = insert(:user)
      listing = insert(:listing, price: 950_000, rooms: 3)
      %{changes: changes} = Listing.changeset(listing, %{price: 1_000_000, rooms: 4}, "user")
      Server.handle_cast({UserEmail, :listing_updated, [user, listing, changes]}, [])
      assert_email_sent(UserEmail.listing_updated(user, listing, changes))
    end
  end
end
