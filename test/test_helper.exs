Application.put_env(:wallaby, :base_url, Estimator.Web.Endpoint.url)
Application.put_env(:wallaby, :screenshot_on_failure, true)

{:ok, _} = Application.ensuredd_all_started(:wallaby)

ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Estimator.Repo, :manual)
