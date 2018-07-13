defmodule Re.ChannelsTest do
  use Re.ModelCase

  doctest Re.Messages.Channels

  import Re.Factory

  alias Re.Messages.Channels

  describe "all/1" do
    test "should return channels belonging to user" do
      admin = insert(:user, role: "admin")
      user = insert(:user, role: "user")
      listing = insert(:listing)

      %{id: channel_id} =
        insert(:channel, participant1: admin, participant2: user, listing: listing)

      assert [%{id: ^channel_id}] = Channels.all(admin)
      assert [%{id: ^channel_id}] = Channels.all(user)
    end
  end

  describe "count_unread/1" do
    test "should count unread messages in a channel" do
      admin = insert(:user, role: "admin")
      user = insert(:user)
      listing = insert(:listing)
      channel = insert(:channel, participant1: admin, participant2: user, listing: listing)

      insert(
        :message,
        channel: channel,
        receiver: admin,
        sender: user,
        listing: listing,
        read: true
      )

      insert(
        :message,
        channel: channel,
        receiver: admin,
        sender: user,
        listing: listing,
        read: false
      )

      insert(
        :message,
        channel: channel,
        receiver: admin,
        sender: user,
        listing: listing,
        read: false
      )

      channel = Channels.get_preloaded(channel.id)

      assert 2 == Channels.count_unread(channel)
    end
  end

  describe "set_last_message/1" do
    test "should set the last message in a channel" do
      admin = insert(:user, role: "admin")
      user = insert(:user)
      listing = insert(:listing)
      channel = insert(:channel, participant1: admin, participant2: user, listing: listing)
      insert(:message, channel: channel, receiver: admin, sender: user, listing: listing)
      insert(:message, channel: channel, receiver: admin, sender: user, listing: listing)

      %{id: message_id} =
        insert(:message, channel: channel, receiver: admin, sender: user, listing: listing)

      channel = Channels.get_preloaded(channel.id)

      assert %{id: ^message_id} = Channels.set_last_message(channel)
    end
  end
end
