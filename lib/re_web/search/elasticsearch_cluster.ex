defmodule ReWeb.ElasticsearchCluster do
  use Elasticsearch.Cluster, otp_app: :re
end
