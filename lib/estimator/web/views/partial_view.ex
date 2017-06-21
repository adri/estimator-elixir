defmodule Estimator.Web.PartialView do
  use Estimator.Web, :view

  def jira_link(issue) do
    Estimator.Issue.IssueFromJira.link(issue)
  end
end
