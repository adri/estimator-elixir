defmodule Estimator.Web.PageView do
  use Estimator.Web, :view

  def partial(template, assigns \\ %{}) do
    render(Estimator.Web.PartialView, template, assigns)
  end

  def estimation_field do
    Estimator.Api.Jira.estimation_field()
  end

  def estimation_to_card(estimation) do
    Estimator.Vote.Card.to_card(estimation)
  end

  def issue_json(issue) do
    Poison.encode!(%{
      key: issue.key,
      summary: issue.summary,
      link: issue.link,
      description: issue.description,
      attachments: Enum.map(issue["fields"]["attachment"] || [], &(&1["content"])),
      type: %{
        iconUrl: issue["fields"]["issuetype"]["iconUrl"],
        name: issue["fields"]["issuetype"]["name"],
      },
    })
  end
end
