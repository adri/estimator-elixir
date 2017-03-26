defmodule Estimator.Moderator do
  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def determine_moderator(user_ids, topic) do
    current = get_for_topic(topic)

    case  Enum.member?(user_ids, current) do
      true -> current
      false -> List.first(user_ids)
    end
  end

  def get_for_topic(topic) do
    Agent.get(__MODULE__, &Map.get(&1, topic))
  end

  def set_for_topic(moderator_id, topic) do
    Agent.update(__MODULE__, &Map.put(&1, topic, moderator_id))
  end
end
