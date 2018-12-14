defmodule ReIntegrations.Pipedrive.ClientTest do
  use Re.ModelCase

  alias ReIntegrations.Pipedrive.Client

  describe "build_uri/3" do
    test "build uri with path" do
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
             } ==
               Client.build_uri("https://example.com/", "", %{attr1: 1, attr2: "text with space"})
    end
  end
end
