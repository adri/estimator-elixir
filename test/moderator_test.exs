defmodule Estimator.ModeratorTest do
  use ExUnit.Case, async: true

  alias Estimator.Moderator

  setup do
    {:ok, moderator} = Moderator.start_link(name: {:global, __MODULE__})
    {:ok, moderator: moderator}
  end

  test ".set moderator for topic", %{moderator: moderator} do
    Moderator.set_for_topic(1, 'topic', moderator)
  end

  test ".get moderator for topic", %{moderator: moderator} do
    Moderator.set_for_topic(1, 'topic', moderator)

    assert Moderator.get_for_topic('topic', moderator) === 1
  end

  test ".determine for topic", %{moderator: moderator} do
    Moderator.set_for_topic(2, 'topic', moderator)

    assert Moderator.determine_moderator([1, 2, 3], 'topic', moderator) === 2
  end
end
