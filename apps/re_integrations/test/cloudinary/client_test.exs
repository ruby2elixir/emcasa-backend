defmodule ReIntegrations.Cloudinary.ClientTest do
  @moduledoc false
  use ReIntegrations.ModelCase

  import ExUnit.CaptureLog

  alias ReIntegrations.Cloudinary.Client

  describe "upload/1" do
    @tag capture_log: true
    test "return only success uploads when failed upload image" do
      assert [_] = Client.upload(["/garage.jpg", "/room.jpg"])
    end

    test "log failed uploads" do
      assert capture_log(fn ->
               Client.upload(["/garage.jpg", "/room.jpg"])
             end) =~
               "Failed to upload images to cloudinary, reason: File /room.jpg does not exist."
    end
  end
end
