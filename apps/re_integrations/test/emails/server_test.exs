defmodule ReIntegrations.Notifications.Emails.ServerTest do
  use Re.ModelCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Listing,
    Repo
  }

  alias ReIntegrations.Notifications.Emails

  describe "handle_cast/2" do
    test "notify_interest/1" do
      interest =
        insert(:interest,
          interest_type: build(:interest_type),
          listing: build(:listing, address: build(:address))
        )

      Emails.Server.handle_info(%{topic: "new_interest", type: :new, new: interest}, [])
      interest = Repo.preload(interest, [:interest_type, listing: :address])
      assert_email_sent(Emails.User.notify_interest(interest))
    end

    test "notify_interest/1 with online scheduling" do
      interest =
        insert(:interest,
          interest_type: build(:interest_type, name: "Agendamento online"),
          listing: build(:listing, address: build(:address))
        )

      Emails.Server.handle_info(%{topic: "new_interest", type: :new, new: interest}, [])
      interest = Repo.preload(interest, [:interest_type, listing: :address])
      email = Emails.User.notify_interest(interest)
      assert_email_sent(email)
      assert [{"", "contato@emcasa.com"}] == email.to
    end

    test "user_registered/1" do
      user = insert(:user)
      Emails.Server.handle_cast({Emails.User, :user_registered, [user]}, [])
      assert_email_sent(Emails.User.user_registered(user))
    end

    test "listing_added_admin/2" do
      user = insert(:user)
      listing = insert(:listing)
      Emails.Server.handle_cast({Emails.User, :listing_added_admin, [user, listing]}, [])
      assert_email_sent(Emails.User.listing_added_admin(user, listing))
    end

    test "should send e-mail when listing is updated" do
      user = insert(:user, role: "user")
      listing = insert(:listing, price: 950_000, rooms: 3, user: user)

      %{changes: changes} =
        changeset = Listing.changeset(listing, %{price: 1_000_000, rooms: 4}, "user")

      Emails.Server.handle_info(
        %{
          topic: "update_listing",
          type: :update,
          content: %{new: listing, changeset: changeset},
          metadata: %{user: user}
        },
        []
      )

      assert_email_sent(Emails.User.listing_updated(listing, user, changes))
    end

    test "should not send e-mail if user is admin" do
      user = insert(:user, role: "admin")
      listing = insert(:listing, price: 950_000, rooms: 3, user: user)

      %{changes: changes} =
        changeset = Listing.changeset(listing, %{price: 1_000_000, rooms: 4}, "admin")

      Emails.Server.handle_info(
        %{
          topic: "update_listing",
          type: :update,
          content: %{new: listing, changeset: changeset},
          metadata: %{user: user}
        },
        []
      )

      assert_email_not_sent(Emails.User.listing_updated(listing, user, changes))
    end
  end

  describe "handle_info/2" do
    test "contact requested by anonymous" do
      request =
        insert(
          :contact_request,
          name: "mahname",
          email: "mahemail@emcasa.com",
          phone: "123321123",
          message: "cool website"
        )

      Emails.Server.handle_info(%{topic: "contact_request", type: :new, new: request}, [])

      assert_email_sent(
        Emails.User.contact_request(%{
          name: "mahname",
          email: "mahemail@emcasa.com",
          phone: "123321123",
          message: "cool website"
        })
      )
    end

    test "contact requested by user" do
      user = insert(:user)
      request = insert(:contact_request, message: "cool website", user: user)

      Emails.Server.handle_info(%{topic: "contact_request", type: :new, new: request}, [])

      assert_email_sent(
        Emails.User.contact_request(%{
          name: user.name,
          email: user.email,
          phone: user.phone,
          message: "cool website"
        })
      )
    end

    test "contact requested by user with new email" do
      user = insert(:user)

      request =
        insert(
          :contact_request,
          message: "cool website",
          user: user,
          email: "different@email.com"
        )

      Emails.Server.handle_info(%{topic: "contact_request", type: :new, new: request}, [])

      assert_email_sent(
        Emails.User.contact_request(%{
          name: user.name,
          email: "different@email.com",
          phone: user.phone,
          message: "cool website"
        })
      )
    end

    test "price suggestion requested when price" do
      address = insert(:address)
      user = insert(:user)
      request = insert(:price_suggestion_request, address: address, user: user, is_covered: false)

      Emails.Server.handle_info(
        %{
          topic: "new_price_suggestion_request",
          type: :new,
          new: %{req: request, price: {:ok, 10.10}}
        },
        []
      )

      assert_email_sent(
        Emails.User.price_suggestion_requested(
          %{
            name: request.name,
            email: request.email,
            area: request.area,
            rooms: request.rooms,
            bathrooms: request.bathrooms,
            garage_spots: request.garage_spots,
            address: %{
              street: address.street,
              street_number: address.street_number
            },
            user: %{
              phone: user.phone
            },
            is_covered: false
          },
          10.10
        )
      )
    end

    test "price suggestion requested for not covered street" do
      address = insert(:address)
      user = insert(:user)
      request = insert(:price_suggestion_request, address: address, user: user, is_covered: true)

      Emails.Server.handle_info(
        %{
          topic: "new_price_suggestion_request",
          type: :new,
          new: %{req: request, price: {:ok, nil}}
        },
        []
      )

      assert_email_sent(
        Emails.User.price_suggestion_requested(
          %{
            name: request.name,
            email: request.email,
            area: request.area,
            rooms: request.rooms,
            bathrooms: request.bathrooms,
            garage_spots: request.garage_spots,
            address: %{
              street: address.street,
              street_number: address.street_number
            },
            user: %{
              phone: user.phone
            },
            is_covered: true
          },
          nil
        )
      )
    end

    test "notify when covered requested" do
      request =
        insert(:notify_when_covered,
          name: "naem",
          phone: "12321",
          email: "user@emcasa.com",
          message: "msg",
          state: "SP",
          city: "São Pauo",
          neighborhood: "Morumbi"
        )

      Emails.Server.handle_info(%{topic: "notify_when_covered", type: :new, new: request}, [])

      assert_email_sent(
        Emails.User.notification_coverage_asked(%{
          name: request.name,
          email: request.email,
          phone: request.phone,
          message: request.message,
          state: request.state,
          city: request.city,
          neighborhood: request.neighborhood
        })
      )
    end

    test "should notify when user schedules a tour appointment" do
      datetime1 = %Re.Calendars.Option{datetime: ~N[2018-05-29 10:00:00]}
      datetime2 = %Re.Calendars.Option{datetime: ~N[2018-05-29 11:00:00]}
      user = insert(:user)
      listing = insert(:listing, user: user)

      tour_appointment =
        insert(:tour_appointment,
          wants_pictures: true,
          wants_tour: true,
          options: [datetime1, datetime2],
          listing: listing,
          user: user
        )

      Emails.Server.handle_info(
        %{topic: "tour_appointment", type: :new, new: tour_appointment},
        []
      )

      assert_email_sent(
        Emails.User.tour_appointment(%{
          wants_pictures: true,
          wants_tour: true,
          options: [datetime1, datetime2],
          user: user,
          listing: listing
        })
      )
    end

    test "should notify when user shows interest in a listing" do
      interest_type = insert(:interest_type)

      interest =
        insert(:interest,
          listing: build(:listing, address: build(:address)),
          interest_type: interest_type
        )

      Emails.Server.handle_info(%{topic: "new_interest", type: :new, new: interest}, [])

      assert_email_sent(Emails.User.notify_interest(interest))
    end

    test "should notify when user inserts a listing" do
      user = insert(:user)
      listing = insert(:listing, user: user)

      Emails.Server.handle_info(%{topic: "new_listing", type: :new, new: listing}, [])

      assert_email_sent(Emails.User.listing_added_admin(user, listing))
    end

    test "should send e-mail when a new site seller lead is added" do
      user = insert(:user)
      address = insert(:address)
      price_suggestion_request = insert(:price_suggestion_request, user: user, address: address)
      site_seller_lead = insert(:site_seller_lead, price_request: price_suggestion_request)

      Emails.Server.handle_info(
        %{
          topic: "new_site_seller_lead",
          type: :new,
          new: site_seller_lead
        },
        []
      )

      assert_email_sent(Emails.User.new_site_seller_lead(site_seller_lead))
    end
  end
end
