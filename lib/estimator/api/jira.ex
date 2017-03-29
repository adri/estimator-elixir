defmodule Estimator.Api.Jira do
  alias Jira.API

  alias Estimator.Vote.Card

  def backlog(board_id) do
    ConCache.get_or_store(:jira_backlog, board_id, fn() -> fetch_backlog(board_id) end)
  end

  def invalidate_backlog(board_id) do
    ConCache.delete(:jira_backlog, board_id)
  end

  defp fetch_backlog(board_id) do
    fields = "summary,description,priority,issuetype,status,#{estimation_field()}"
    expand = "renderedFields"
    API.get!("/rest/agile/1.0/board/#{board_id}/backlog?fields=#{fields}&expand=#{expand}").body
  end

  def backlog_filter(backlog, selected_issues) do
    keys = Enum.map(selected_issues, &(&1.key))

    %{backlog |
      "issues" => backlog["issues"] |> Enum.filter(&(!Enum.member?(keys, &1["key"])))
    }
  end

  def set_estimation(issue_key, estimation) do
    API.put!(
      "/rest/api/2/issue/#{issue_key}",
      Poison.encode!(%{"fields" => %{"#{estimation_field()}" => Card.to_number(estimation)}}),
      [{"Content-type", "application/json"}]
    )
  end

  def estimation_field do
    Application.get_env(:jira, :estimation_field, System.get_env("JIRA_ESTIMATION_FIELD"))
  end
end
