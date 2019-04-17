defmodule Re.Tags.DataloaderTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Tag,
    Tags
  }

  setup do
    public_tags = [
      insert(:tag,
        name: "Party room",
        name_slug: "party-room",
        category: "infrastructure"
      ),
      insert(:tag,
        name: "Gym",
        name_slug: "gym",
        category: "infrastructure"
      )
    ]

    private_tags = [
      insert(:tag,
        name: "Pool",
        name_slug: "pool",
        category: "infrastructure",
        visibility: "private"
      ),
      insert(:tag,
        name: "Playground",
        name_slug: "playground",
        category: "infrastructure",
        visibility: "private"
      )
    ]

    {
      :ok,
      public_tags: public_tags, private_tags: private_tags
    }
  end

  test "admin user should fetch tags with private visibility" do
    loader =
      Dataloader.add_source(
        Dataloader.new(),
        :tags,
        Tags.data(%{user: %{role: "admin"}})
      )

    loader =
      loader
      |> Dataloader.load(
        :tags,
        {:many, Tag},
        visibility: "private"
      )
      |> Dataloader.run()

    tags = Dataloader.get(loader, :tags, {:many, Tag}, visibility: "private")

    assert 2 == Enum.count(tags)
  end

  test "regular user should not fetch tags with private visibility" do
    loader =
      Dataloader.add_source(
        Dataloader.new(),
        :tags,
        Tags.data(%{user: %{role: "user"}})
      )

    loader =
      loader
      |> Dataloader.load(
        :tags,
        {:many, Tag},
        visibility: "private"
      )
      |> Dataloader.run()

    tags = Dataloader.get(loader, :tags, {:many, Tag}, visibility: "private")

    assert [] == tags
  end

  test "anonymous user should not fetch tags with private visibility" do
    loader =
      Dataloader.add_source(
        Dataloader.new(),
        :tags,
        Tags.data(%{user: nil})
      )

    loader =
      loader
      |> Dataloader.load(
        :tags,
        {:many, Tag},
        visibility: "private"
      )
      |> Dataloader.run()

    tags = Dataloader.get(loader, :tags, {:many, Tag}, visibility: "private")

    assert [] == tags
  end
end
