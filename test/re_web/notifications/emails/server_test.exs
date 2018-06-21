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

    test "notify_interest/1 with online scheduling" do
      interest =
        insert(:interest, interest_type: build(:interest_type, name: "Agendamento online"))

      Server.handle_cast({UserEmail, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      email = UserEmail.notify_interest(interest)
      assert_email_sent(email)
      assert [{"", "contato@emcasa.com"}] == email.to
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

    test "price_updated/2" do
      user1 = insert(:user)
      user2 = insert(:user)
      user3 = insert(:user, notification_preferences: %{email: false})
      user4 = insert(:user, confirmed: false)
      listing = insert(:listing, price: 950_000)
      insert(:listings_favorites, user: user1, listing: listing)
      insert(:listings_favorites, user: user2, listing: listing)
      insert(:listings_favorites, user: user3, listing: listing)
      insert(:listings_favorites, user: user4, listing: listing)

      Server.handle_cast({UserEmail, :price_updated, 1_000_000, listing}, [])
      assert_email_sent(UserEmail.price_updated(user1, 1_000_000, listing))
      assert_email_sent(UserEmail.price_updated(user2, 1_000_000, listing))
      assert_email_not_sent(UserEmail.price_updated(user3, 1_000_000, listing))
      assert_email_not_sent(UserEmail.price_updated(user4, 1_000_000, listing))
    end
  end
end
