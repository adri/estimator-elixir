defmodule Estimator.Api.Jira do
  alias Jira.API

  def backlog(board_id) do
    ConCache.dirty_get_or_store(:jia_backlog, board_id, fn() ->
        fields = "summary,priority,issuetype,status,#{estimation_field}";
        API.get!("/rest/agile/1.0/board/#{board_id}/backlog?fields=#{fields}").body
    end)
  end

  def issue(issue_id) do
    API.ticket_details(issue_id)
  end

  def add_estimation(estimation) do
#    body = estimation |> Poison.encode!
#    estimation_field
#    API.post!("/rest/api/2/issue/#{key}/watchers", body, [{"Content-type", "application/json"}])
  end

  defp estimation_field do
    Application.get_env(:jira, :estimation_field, System.get_env("JIRA_ESTIMATION_FIELD"))
  end
end
