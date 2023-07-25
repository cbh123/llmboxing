import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :boxing, BoxingWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  url: [scheme: "https", host: "modelstreetfight.com", port: 443],
  # force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: [
    "https://modelfight.fly.dev",
    "https://llmboxing.com"
  ]

config :boxing, :env, :prod

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Boxing.Finch

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
