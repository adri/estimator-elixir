defmodule Estimator.Issue do
  import Ecto.Query

  alias Estimator.Repo
  alias Estimator.Issue.{
    SelectedIssue,
    IssueFromJira,
  }

  @spec list_selected :: [SelectedIssue.t]
  def list_selected do
    SelectedIssue
    |> where(selected: true)
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  @spec list_to_estimate :: [SelectedIssue.t]
  def list_to_estimate do
    SelectedIssue
    |> where(selected: true)
    |> where([s], is_nil(s.estimation))
    |> where([s], s.inserted_at >= ^Timex.beginning_of_day(Timex.now))
    |> where([s], s.inserted_at <= ^Timex.end_of_day(Timex.now))
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  @spec insert_jira_issue(map) ::
      {:ok, SelectedIssue.t} |
      {:error, Ecto.Changeset.t}
  def insert_jira_issue(params) do
    IssueFromJira.create(params)
    |> Repo.insert!
  end

#  @spec set_estimation(String.t, String.t) ::
#      {:ok, SelectedIssue.t} |
#      {:error, Ecto.Changeset.t}
  def set_estimation(issue_key, estimation) do
    SelectedIssue
    |> Repo.get(issue_key)
    |> SelectedIssue.changeset_update_estimation(%{key: issue_key, estimation: estimation})
    |> Repo.update
  end
end
