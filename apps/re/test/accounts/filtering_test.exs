defmodule Re.Accounts.FilteringTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Filtering,
    Repo
  }

  import Re.Factory

  describe "apply/2" do
    test "filter by phone number" do
      user_1 = insert(:user, phone: "(99)999999999")
      insert(:user, phone: "(88)88888888")

      result =
        Filtering.apply(Re.User, %{search: "999"})
        |> Repo.all()

      assert result == [user_1]
    end

    test "filter by user name not considering case" do
      user_1 = insert(:user, name: "Alice")
      insert(:user, name: "Bob")

      result =
        Filtering.apply(Re.User, %{search: "ali"})
        |> Repo.all()

      assert result == [user_1]
    end

    test "filter by user email not considering case" do
      user_1 = insert(:user, email: "alice@gmail.com")
      insert(:user, email: "bob@bol.com")

      result =
        Filtering.apply(Re.User, %{search: "GMAIL"})
        |> Repo.all()

      assert result == [user_1]
    end
  end
end
