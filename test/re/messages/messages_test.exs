defmodule Re.MessagesTest do
  use Re.ModelCase

  doctest Re.Messages

  import Re.Factory

  alias Re.Messages

  describe "get/1" do
    test "should return received messages as well when filtering by sender" do
      [user1, user2, user3] = insert_list(3, :user)
      listing = insert(:listing)

      %{id: msg1} = insert(:message, receiver: user1, sender: user2, listing: listing)
      %{id: msg2} = insert(:message, receiver: user2, sender: user1, listing: listing)
      insert(:message, receiver: user1, sender: user3, listing: listing)
      insert(:message, receiver: user1, sender: user3, listing: listing)

      assert [
               %{id: ^msg1},
               %{id: ^msg2}
             ] = Messages.get(user1, %{listing_id: listing.id, sender_id: user2.id})
    end
  end
end
