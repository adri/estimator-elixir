defmodule Estimator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :estimator,
      version: "0.0.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      # build_path: System.get_env("MIX_BUILD_PATH") || '_build',
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Estimator.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0-rc", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:poison, "~> 3.1.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_github, "~> 0.4"},
      {:jira, "~> 0.0.8"},
      {:con_cache, "~> 0.12.0"},
      {:guardian, "~> 0.14"},
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
      {:browser, "~> 0.3"},
      {:sentry, "~> 6.0", only: [:prod]},
      # Dev
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:test, :dev], runtime: false},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      # Test only
      {:junit_formatter, "~> 1.3", only: [:test]}
    ]
  end

  #     {:excheck, "~> 0.5", only: :test},
  #     {:triq, github: "triqng/triq", only: :test}
  #     {:xprof, "~> 1.2.1"}

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
