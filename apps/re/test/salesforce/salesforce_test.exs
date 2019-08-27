defmodule Re.SalesforceTest do
  use Re.ModelCase

  alias Re.Salesforce

  describe "flatten_map/1" do
    test "merge all associations on object root" do
      object = %{
        "attributes" => %{
          "type" => "Opportunity",
          "url" => "/services/data/v42.0/sobjects/Opportunity/a"
        },
        "Id" => "006f400000QVAxjAAH",
        "Name" => "Foo",
        "Account" => %{
          "attributes" => %{
            "type" => "Account",
            "url" => "/services/data/v42.0/sobjects/Account/b"
          },
          "Name" => "Bar"
        },
        "Owner" => %{
          "attributes" => %{
            "type" => "User",
            "url" => "/services/data/v42.0/sobjects/User/c"
          },
          "Age" => "18",
          "Name" => "Baz"
        }
      }

      assert Salesforce.flatten_map(object) == %{
               "Id" => "006f400000QVAxjAAH",
               "Name" => "Foo",
               "AccountName" => "Bar",
               "OwnerAge" => "18",
               "OwnerName" => "Baz"
             }
    end
  end
end
