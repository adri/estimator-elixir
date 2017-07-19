defmodule Estimator.GraphQL.SessionResolver do

  alias Estimator.Moderator

  def current(_args, _context) do
    board_id = 1
    {:ok, %{moderator: Moderator.get_or_elect([1], board_id)}}
  end
end