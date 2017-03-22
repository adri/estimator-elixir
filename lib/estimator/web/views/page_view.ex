defmodule Estimator.Web.PageView do
  use Estimator.Web, :view

  def partial(template, assigns \\ %{}) do
    render(Estimator.Web.PartialView, template, assigns)
  end


  def jira_link(issue) do
    Estimator.Issue.IssueFromJira.link(issue)
  end

  def issue_json(issue) do
    Poison.encode!(%{
      key: issue.key,
      summary: issue.summary,
      link: issue.link,
      description: issue.description
    })
  end
end
