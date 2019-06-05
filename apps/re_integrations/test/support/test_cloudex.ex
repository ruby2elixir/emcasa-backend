defmodule ReIntegrations.TestCloudex do
  @moduledoc false

  def upload(_image_list) do
    [
      ok: %Cloudex.UploadedImage{
        bytes: 1_919_630,
        context: nil,
        created_at: "2019-06-04T10:09:22Z",
        etag: "9d5de4b64cd4fae81bab758f81abded1",
        format: "jpg",
        height: 2684,
        moderation: nil,
        original_filename: "c",
        phash: nil,
        public_id: "qxo1cimsxmb2vnu5kcxw",
        resource_type: "image",
        secure_url:
          "https://res.cloudinary.com/emcasa/image/upload/v1559642962/qxo1cimsxmb2vnu5kcxw.jpg",
        signature: "xxx",
        source: "/home/room.jpg",
        tags: [],
        type: "upload",
        url: "http://res.cloudinary.com/emcasa/image/upload/v1559642962/qxo1cimsxmb2vnu5kcxw.jpg",
        version: 1_559_642_962,
        width: 2025
      },
      error: "File /do/not/exists does not exist."
    ]
  end
end
