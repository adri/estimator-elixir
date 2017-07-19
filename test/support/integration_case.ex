defmodule Estimator.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Estimator.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Estimator.Web.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Estimator.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Estimator.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Estimator.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end