use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :estimator, Estimator.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :junit_formatter,
  report_file: "junit.xml",
  report_dir: "/tmp",
  print_report_file: true

# Configure your database
config :estimator, Estimator.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  database: System.get_env("DATABASE_DB") || "estimator_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :wallaby, screenshot_on_failure: true

config :estimator, :sql_sandbox, true