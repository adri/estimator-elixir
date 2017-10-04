defmodule Estimator.Web.EstimationChannel do
  @moduledoc """
  Phoenix Channel for estimations.

  Channel names are combined @topic_prefix and board id.
  """
  use Estimator.Web, :channel
  @topic_prefix "estimation:"

  alias Estimator.{
    Moderator,
    Votes,
    Issue,
    Issue.CurrentIssue,
    Web.VoteView,
    Web.Presence,
  }

  def join(@topic_prefix <> _board_id, _params, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def join(_other, _params, _socket) do
    {:error, "No estimation"}
  end

  def terminate(_reason, socket) do
    broadcast! socket, "user:away", user_data(socket, %{status: "away"})
  end

  def handle_info(:after_join, socket) do
    socket
      |> track_presence
      |> determine_moderator
      |> send_current_moderator
      |> send_current_issue
      |> send_current_votes

    {:noreply, socket}
  end

  def handle_in("vote:new", message, socket) do
    {:ok, vote} = Votes.insert_vote(%{
      topic: socket.topic,
      user_id: socket.assigns.user["id"],
      issue_key: message["issue_key"],
      vote: message["vote"],
    })

    broadcast! socket, "vote:new", VoteView.render("vote.json", vote)

    {:noreply, socket}
  end

  def handle_in("issue:set", message, socket) do
    CurrentIssue.set_for_topic(message["issue_key"], socket.topic)
    broadcast! socket, "issue:set", message(%{issue_key: message["issue_key"]})

    {:noreply, socket}
  end

  def handle_in("moderator:set", user_id, socket) do
    Moderator.set_for_topic(user_id, socket.topic)
    broadcast! socket, "moderator:set", message(%{moderator_id: user_id})

    {:noreply, socket}
  end

  def handle_in("estimation:set", %{"issue_key" => issue_key, "estimation" => estimation}, socket) do
    Issue.set_estimation(issue_key, estimation)

    broadcast! socket, "estimation:set", message(%{
      issue_key: issue_key,
      estimation: estimation,
    })

    push socket, "estimation:stored", message(%{issue_key: issue_key})

    {:noreply, socket}
  end

  def handle_in("estimation:skip", %{"issue_key" => issue_key}, socket) do
    Issue.skip_estimation(issue_key)

    broadcast! socket, "estimation:set", message(%{
      issue_key: issue_key,
      estimation: "skipped",
    })

    {:noreply, socket}
  end

  def handle_in("issue:start_edit", %{"issue_key" => issue_key}, socket) do
    broadcast! socket, "issue:start_edit", message(%{
      issue_key: issue_key,
    })

    {:noreply, socket}
  end

  def handle_in("issue:stop_edit", %{"issue_key" => issue_key}, socket) do
    broadcast! socket, "issue:stop_edit", message(%{
      issue_key: issue_key,
    })

    {:noreply, socket}
  end

  defp track_presence(socket) do
    push socket, "players_state", Presence.list(socket)
    Presence.track(socket, user_id(socket), user_data(socket))

    socket
  end

  defp determine_moderator(socket) do
    socket
      |> Presence.list
      |> Map.keys
      |> Moderator.determine_moderator(socket.topic)
      |> Moderator.set_for_topic(socket.topic)

    socket
  end

  defp send_current_moderator(socket) do
     broadcast! socket, "moderator:current", message(%{
       "moderator_id": Moderator.get_for_topic(socket.topic)
     })

     socket
  end

  defp send_current_issue(socket) do
    push socket, "issue:current", message(%{
      "issue_key": CurrentIssue.get_for_topic(socket.topic)
    })

    socket
  end

  defp send_current_votes(socket) do
    socket
      |> board_id
      |> Issue.list_to_estimate
      |> Enum.map(&(&1.key))
      |> Enum.each(fn issue ->
        push socket, "vote:current", %{
          "issue_key" => issue,
          "votes" => Votes.for_topic_and_issue(socket.topic, issue)
        }
      end)

    socket
  end

  defp board_id(socket) do
    @topic_prefix <> board_id = socket.topic

    board_id
  end

  defp user_id(socket) do
    socket.assigns.user["id"]
  end

  defp user_data(socket, override \\ %{}) do
    Map.merge %{
      online_at: :os.system_time(:milli_seconds),
      user: socket.assigns.user,
      last_vote: nil,
      status: "online",
    }, override
  end

  defp message(data) do
    Map.merge %{
      timestamp: :os.system_time(:milli_seconds),
    }, data
  end

end
