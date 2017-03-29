defmodule Estimator.Web.PageController do
  use Estimator.Web, :controller

  alias Estimator.Api.Jira
  alias Estimator.Issue
  alias Estimator.Issue.SelectedIssue

  plug Ueberauth

  def login(conn, _params) do
    render conn, current_user: false
  end


  def index(conn, _params) do
    redirect(conn, to: page_path(conn, :backlog, board_id()))
  end

  def backlog(conn, %{"board_id" => board_id}) do
    backlog = board_id
      |> Jira.backlog
      |> Jira.backlog_filter(Issue.list_selected(board_id))
      |> Jira.backlog_filter_estimated

    template conn, board_id, backlog: backlog
  end

  def backlog_refresh(conn, %{"board_id" => board_id}) do
    Jira.invalidate_backlog(board_id)

    conn
      |> put_flash(:success, "Updated issues from Jira")
      |> redirect(to: page_path(conn, :backlog, board_id))
  end

  def estimate(conn, %{"board_id" => board_id}) do
    template conn, board_id, selected_issues: Issue.list_to_estimate(board_id)
  end

  def estimated(conn, %{"board_id" => board_id}) do
    template conn, board_id, issues: Issue.list_estimated(board_id)
  end

  def select_issues(conn, %{"selected_issue" => issues, "board_id" => board_id}) do
    selected_issues = for {issue, selected} <- issues, selected == "true", do: issue
    Issue.import_issues_from_jira(board_id, selected_issues)

    success(conn, "Issue selected", page_path(conn, :estimate, board_id))
  end

  def deselect_issue(conn, %{"issue_key" => issue_key, "board_id" => board_id}) do
    Issue.deselect(issue_key)

    success(conn, "Issue deselected", page_path(conn, :estimate, board_id))
  end

  def unauthenticated(conn, _) do
    redirect(conn, to: "/login")
  end

 # ---

 defp template(conn, board_id, assigns) do
    render conn, Keyword.merge(assigns, [
        current_user: get_session(conn, :current_user),
        changeset: SelectedIssue.changeset(%SelectedIssue{}),
        board_id: board_id
      ])
 end

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
