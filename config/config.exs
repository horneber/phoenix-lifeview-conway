# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :life, LifeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0hw+j5SQ7rIh0JYmFw2nr7rcDVqzEQ6FLet8ZRxA9qAttPhKV/+tcIfym2n/6ehV",
  render_errors: [view: LifeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Life.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "uopoQtIC9j4kSWQYPaTXGxfeB8SVAWQuV2zBNuw9tKDGAqh9pMyxyH79yUEZ0wsR"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, 
  json_library: Jason,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
