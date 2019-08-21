defmodule Re.InterestsTest do
  use Re.ModelCase

  alias Re.{
    BuyerLeads,
    Interest,
    Interests,
    Repo
  }

  import Re.Factory
  import Re.CustomAssertion

  describe "show_interest/1" do
    test "should create interest in listing" do
      Re.PubSub.subscribe("new_interest")
      listing = insert(:listing)

      {:ok, interest} =
        Interests.show_interest(%{
          name: "naem",
          phone: "123",
          listing_id: listing.id
        })

      assert interest = Repo.get(Interest, interest.id)
      assert interest.uuid
      assert_receive %{new: _, topic: "new_interest", type: :new}
      assert_enqueued_job(Repo.all(BuyerLeads.JobQueue), "interest")
    end

    test "should not create interest in invalid listing" do
      Re.PubSub.subscribe("new_interest")

      {:error, :add_interest, _, _} =
        Interests.show_interest(%{name: "naem", phone: "123", listing_id: -1})

      refute_receive %{new: _, topic: "new_interest", type: :new}
    end
  end
end
