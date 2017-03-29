defmodule Estimator.Issue.IssueFromJira do
  alias Estimator.Issue.SelectedIssue

  def create(board_id, jira_issue) do
    %SelectedIssue{
      key: jira_issue["key"],
      board_id: String.to_integer(board_id),
      link: link(jira_issue),
      selected: true,
      summary: jira_issue["fields"]["summary"],
      description: jira_issue["renderedFields"]["description"],
      raw: jira_issue,
    }
  end

  def link(jira_issue) do
    [domain, _rest] = String.split(jira_issue["self"], "/rest", parts: 2)

    "#{domain}/browse/#{jira_issue["key"]}"
  end

end
