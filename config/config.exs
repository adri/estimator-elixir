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
  loggers: [Ecto.LogEntry]

# Configures the endpoint
config :estimator, Estimator.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "2+nLPwNw0i/b/03tm21Utu/uZC1VN8lSG/VgMmMxy2gw5N1C6KCdstgTGQljZuKg",
  render_errors: [view: Estimator.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Estimator.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [uid_field: "login"]},
  ]

config :guardian, Guardian,
  verify_module: Guardian.JWT,
  allowed_algos: ["HS512"], # optional
  issuer: "Estimator",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key:  System.get_env("SECRET_KEY_BASE") || "2+nLPwNw0i/b/03tm21Utu/uZC1VN8lSG/VgMmMxy2gw5N1C6KCdstgTGQljZuKg",
  serializer: Estimator.Auth.GuardianSerializer

config :sentry,
  dsn: System.get_env("SENTRY_DSN") || "https://public:secret@app.getsentry.com/1",
  environment_name: Mix.env,
  included_environments: [:prod],
  enable_source_code_context: true,
  root_source_code_path: File.cwd!

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
