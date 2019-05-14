defmodule Re.Accounts.FilteringTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Filtering,
    Repo,
    User
  }

  import Re.Factory

  describe "apply/2" do
    test "filter by phone number" do
      user = insert(:user, phone: "(99)999999999")

      {:ok, _other_user} =
        %User{phone: "(88)888888888"}
        |> Repo.insert()

      result =
        User
        |> Filtering.apply(%{search: "999"})
        |> Repo.all()

      assert result == [user]
    end

    test "filter by user name not considering case" do
      user = insert(:user, name: "Alice")

      {:ok, _other_user} =
        %User{name: "Bob"}
        |> Repo.insert()

      result =
        User
        |> Filtering.apply(%{search: "ali"})
        |> Repo.all()

      assert result == [user]
    end

    test "filter by user email not considering case" do
      user = insert(:user, email: "alice@gmail.com")

      {:ok, _other_user} =
        %User{email: "bob@bol.com"}
        |> Repo.insert()

      result =
        User
        |> Filtering.apply(%{search: "GMAIL"})
        |> Repo.all()

      assert result == [user]
    end
  end
end
