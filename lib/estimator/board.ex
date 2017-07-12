defmodule Estimator.Board do
  import Ecto.Query

  alias Estimator.Repo
  alias Estimator.Vote.Vote
  alias Estimator.Issue.SelectedIssue

  @doc """
  Returns the last used board id or null.
  """
  def last_used_board_id(user_id) do
      query = from v in Vote,
       join: i in SelectedIssue, on: i.key == v.issue_key,
       where: v.user_id == ^user_id,
       order_by: [desc: v.inserted_at],
       limit: 1,
       select: i.board_id
       Repo.one(query)
  end
end
