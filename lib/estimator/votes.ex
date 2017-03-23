defmodule Estimator.Votes do
  import Ecto.Query

  alias Estimator.Repo
  alias Estimator.Vote.Vote

  @spec insert_vote(map) ::
      {:ok, Vote.t} |
      {:error, Ecto.Changeset.t}
  def insert_vote(params) do
    %Vote{}
    |> Vote.changeset(params)
    |> Repo.insert
  end

  def for_issue(issue_key) do
  end
end
