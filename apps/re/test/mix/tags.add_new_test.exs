defmodule Mix.Tasks.Re.Tags.AddNewTest do
  use Re.ModelCase

  alias Mix.Tasks.Re.Tags

  alias Re.{
    Repo,
    Tag
  }

  setup do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end

  describe "run/1" do
    test "insert at least one tag" do
      Tags.AddNew.run([])

      refute [] == Repo.all(Tag)
    end
  end
end
