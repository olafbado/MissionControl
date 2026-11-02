import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fuel_calculator, FuelCalculatorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "phzg8Wzk2i+jB7Yq4kVpYTNqf+530ezK4oGZbp5pi3RWWfF4OG9epE5RuGr6YXK5",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
