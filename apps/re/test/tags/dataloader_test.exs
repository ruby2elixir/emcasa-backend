defmodule Re.Tags.DataloaderTest do
  use Re.ModelCase

  alias Re.{
    Tag,
    Tags
  }

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

    assert 3 == Enum.count(tags)
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

    assert 0 == Enum.count(tags)
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

    assert 0 == Enum.count(tags)
  end
end
