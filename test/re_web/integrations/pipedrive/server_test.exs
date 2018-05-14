defmodule ReWeb.Integrations.Pipedrive.ServerTest do
  use Re.ModelCase

  doctest ReWeb.Integrations.Pipedrive.Client

  alias ReWeb.Integrations.Pipedrive.Client

  describe "handle_cast/2" do
    test "mark listing as done" do
      assert %URI{
          authority: "example.com",
          host: "example.com",
          port: 443,
          scheme: "https",
          path: "/with_path",
          query: ""
        } == Client.build_uri("https://example.com", "with_path", %{})
    end

    test "build uri with query" do
      assert %URI{
          authority: "example.com",
          host: "example.com",
          port: 443,
          scheme: "https",
          query: "attr1=1&attr2=text+with+space",
          path: "/"
        } == Client.build_uri("https://example.com/", "", %{attr1: 1, attr2: "text with space"})
    end
  end
end
