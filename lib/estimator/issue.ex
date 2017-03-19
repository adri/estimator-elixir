defmodule Estimator.Issue do

  import Ecto.Query

  alias Estimator.Issue.{
    SelectedIssue,
  }

  @spec list_selected_issues :: [SelectedIssue.t]
  def list_selected_issues do
    SelectedIssue
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  @spec insert_issue(map) ::
      {:ok, SelectedIssue.t} |
      {:error, Ecto.Changeset.t}
  def insert_issue(params) do
    %SelectedIssue{}
    |> SelectedIssue.changeset(params)
    |> Repo.insert
  end
end
