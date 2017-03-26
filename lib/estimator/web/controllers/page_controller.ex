defmodule Estimator.Web.PageController do
  use Estimator.Web, :controller

  alias Estimator.Api.Jira
  alias Estimator.Issue
  alias Estimator.Issue.{
    SelectedIssue,
    IssueFromJira
  }

  plug Ueberauth

  def login(conn, _params) do
    render conn, current_user: get_session(conn, :current_user)
  end

  def backlog(conn, _params) do
    backlog = Jira.backlog(board_id())
      |> Jira.backlog_filter(Issue.list_selected)

    render conn,
      backlog: backlog,
      current_user: get_session(conn, :current_user),
      changeset: SelectedIssue.changeset(%SelectedIssue{})
  end

  def estimate(conn, _params) do
    render conn,
      current_user: get_session(conn, :current_user),
      selected_issues: Issue.list_to_estimate(),
      changeset: SelectedIssue.changeset(%SelectedIssue{})
  end

  def estimated(conn, _params) do
    render conn,
      issues: Issue.list_estimated(),
      current_user: get_session(conn, :current_user)
  end

  def select_issues(conn, %{"selected_issue" => issues}) do
    issues = for {issue, selected} <- issues, selected == "true", do: issue
    Jira.backlog(board_id())["issues"]
      |> Enum.filter(&(Enum.member?(issues, &1["key"]) ))
      |> Enum.map(&(Issue.insert_jira_issue(&1)))

    success(conn, "Issue selected", page_path(conn, :estimate))
  end

  def unauthenticated(conn, _) do
      conn
      |> redirect(to: "/login")
  end

 # ---

  defp board_id do
    Application.get_env(:jira, :board_id, System.get_env("JIRA_BOARD_ID"))
  end

  defp success(conn, message, redirect_path) do
    msg(conn, :success, message, redirect_path)
  end

  defp msg(conn, type, message, redirect_path) do
      conn
      |> put_flash(type, message)
      |> redirect(to: redirect_path)
    end
end
