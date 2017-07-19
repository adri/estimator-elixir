defmodule Estimator.Moderator do
  @moduledoc """
  Stores moderator for a specified topic.
  """
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> MapSet.new end, opts)
  end

  def determine_moderator(user_ids, topic, name \\ @name) do
    current = get_for_topic(topic, name)

    case  Enum.member?(user_ids, current) do
      true -> current
      false -> List.first(user_ids)
    end
  end

  def get_for_topic(topic, name \\ @name) do
    Agent.get(name, &Map.get(&1, topic))
  end

  def set_for_topic(moderator_id, topic, name \\ @name) do
    Agent.update(name, &Map.put(&1, topic, moderator_id))
  end
end
