defmodule Estimator.Issue do
  import Ecto.Query

  alias Estimator.Repo
  alias Estimator.Issue.{
    SelectedIssue,
    IssueFromJira,
  }
  alias Estimator.Api.Jira

  @type issue_key :: String.t

  def list_selected(board_id) do
    SelectedIssue
    |> where(selected: true)
    |> where(board_id: ^board_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  def list_to_estimate(board_id) do
    SelectedIssue
    |> where(selected: true)
    |> where(board_id: ^board_id)
    |> where([s], is_nil(s.estimation)
      or (not is_nil(s.estimation)
        and s.updated_at >= ^Timex.beginning_of_day(Timex.now)
        and s.updated_at <= ^Timex.end_of_day(Timex.now)))
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  def list_estimated(board_id) do
    SelectedIssue
    |> where(selected: true)
    |> where(board_id: ^board_id)
    |> where([s], not is_nil(s.estimation))
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  def import_issues_from_jira(board_id, selected_issues) do
    board_id
    |> Jira.backlog
    |> get_in(["issues"])
    |> Enum.filter(&(Enum.member?(selected_issues, &1["key"])))
    |> Enum.each(&(insert_jira_issue(board_id, &1)))
  end

  def insert_jira_issue(board_id, params) do
    IssueFromJira.create(board_id, params)
    |> Repo.insert!
  end

  def deselect(issue_key) do
    SelectedIssue
    |> where(key: ^issue_key)
    |> Repo.delete_all
  end

  def set_estimation(issue_key, estimation) do
    Jira.set_estimation(issue_key, estimation)
    SelectedIssue
    |> Repo.get_by(key: issue_key)
    |> SelectedIssue.changeset_update_estimation(%{key: issue_key, estimation: estimation})
    |> Repo.update
  end

  def skip_estimation(issue_key) do
    SelectedIssue
    |> Repo.get_by(key: issue_key)
    |> SelectedIssue.changeset_update_estimation(%{key: issue_key, estimation: "skipped"})
    |> Repo.update
  end
end
