defmodule Estimator.Web.VoteView do
  use Estimator.Web, :view

  def render("vote.json", vote) do
    %{
      issue_key: vote.issue_key,
      user_id: vote.user_id,
      vote: vote.vote,
      timestamp: :os.system_time(:milli_seconds),
    }
  end
end
