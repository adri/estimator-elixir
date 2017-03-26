defmodule Estimator.Api.Jira do
  alias Jira.API

  def backlog(board_id) do
    ConCache.dirty_get_or_store(:jia_backlog, board_id, fn() ->
        fields = "summary,description,priority,issuetype,status,#{estimation_field()}";
        expand = "renderedFields";
        API.get!("/rest/agile/1.0/board/#{board_id}/backlog?fields=#{fields}&expand=#{expand}").body
    end)
  end

  def backlog_filter(backlog, selected_issues) do
    keys = Enum.map(selected_issues, &(&1.key))

    %{backlog |
      "issues" => backlog["issues"] |> Enum.filter(&(!Enum.member?(keys, &1["key"]) ))
    }
  end

  def set_estimation(issue_key, estimation) do
    cardMap = %{
      "XS" => 1,
      "S" => 2,
      "M" => 4,
      "L" => 8,
      "XL" => 16,
    }

    API.put!(
      "/rest/api/2/issue/#{issue_key}",
      Poison.encode!(%{ "fields" => %{"#{estimation_field}" => cardMap[estimation] } }),
      [{"Content-type", "application/json"}]
    )
  end

  defp estimation_field do
    Application.get_env(:jira, :estimation_field, System.get_env("JIRA_ESTIMATION_FIELD"))
  end
end
