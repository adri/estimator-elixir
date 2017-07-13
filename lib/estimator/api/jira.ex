defmodule Estimator.Api.Jira do
  alias Jira.API

  alias Estimator.Vote.Card

  def backlog(board_id) do
    ConCache.get_or_store(:jira_backlog, board_id, fn() -> fetch_backlog(board_id) end)
  end

  def invalidate_backlog(board_id) do
    ConCache.delete(:jira_backlog, board_id)
  end

  def backlog_filter(backlog, without_issues) do
    keys = Enum.map(without_issues, &(&1.key))
    filtered_issues = backlog["issues"]
      |> Enum.filter(&(!Enum.member?(keys, &1["key"])))

    put_in(backlog, ["issues"], filtered_issues)
  end

  def backlog_filter_estimated(backlog) do
    filtered_issues = backlog["issues"]
      |> Enum.filter(&(is_nil &1["fields"][estimation_field()]))

    put_in(backlog, ["issues"], filtered_issues)
  end

  def set_estimation(issue_key, estimation) do
    API.put!(
      "/rest/api/2/issue/#{issue_key}",
      Poison.encode!(%{"fields" => %{"#{estimation_field()}" => Card.to_number(estimation)}}),
      [{"Content-type", "application/json"}],
      ssl: [{:versions, [:'tlsv1.2']}]
    )
  end

  def estimation_field do
    Application.get_env(:jira, :estimation_field, System.get_env("JIRA_ESTIMATION_FIELD"))
  end

  # ---

  defp fetch_backlog(board_id) do
    fields = "summary,description,priority,issuetype,status,reporter,flagged,#{estimation_field()}"
    expand = "renderedFields"
    API.get!("/rest/agile/1.0/board/#{board_id}/backlog?fields=#{fields}&expand=#{expand}", [], [ ssl: [{:versions, [:'tlsv1.2']}] ]).body
  end
end
