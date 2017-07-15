# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :estimator,
  ecto_repos: [Estimator.Repo]

config :estimator, Estimator.Repo,
  loggers: [PryIn.EctoLogger, Ecto.LogEntry]

# Configures the endpoint
config :estimator, Estimator.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "2+nLPwNw0i/b/03tm21Utu/uZC1VN8lSG/VgMmMxy2gw5N1C6KCdstgTGQljZuKg",
  render_errors: [view: Estimator.Web.ErrorView, accepts: ~w(html json)],
  instrumenters: [PryIn.Instrumenter],
  pubsub: [name: Estimator.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [uid_field: "login"] },
  ]

config :guardian, Guardian,
  verify_module: Guardian.JWT,
  allowed_algos: ["HS512"], # optional
  issuer: "Estimator",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key:  System.get_env("SECRET_KEY_BASE") || "2+nLPwNw0i/b/03tm21Utu/uZC1VN8lSG/VgMmMxy2gw5N1C6KCdstgTGQljZuKg",
  serializer: Estimator.Auth.GuardianSerializer

config :pryin,
  otp_app: :estimator,
  api_key: "j29oa4142c8q33sogifnm1qgsab3fvtif4r3spl90c2or5jr",
  enabled: false,
  env: :dev

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
