defmodule Estimator.Web.EstimationChannel do
  use Estimator.Web, :channel

 alias Estimator.{
    Moderator,
    Votes,
    Issue,
    Issue.CurrentIssue,
    Web.VoteView,
    Web.Presence,
  }

  def join("estimation:ticketswap", _params, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def join(_other, _params, _socket) do
    {:error, "No estimation"}
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

#  def leave(_other, _params, socket) do
#    if (socket.assigns.user["id"] == Moderator.get_for_topic(socket.topic)) do
#      Moderator.set_for_topic(socket.topic, nil)
#    end
#    socket
#  end

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
    broadcast! socket, "issue:set", %{issue_key: message["issue_key"]}

    {:noreply, socket}
  end

  def handle_in("moderator:set", user_id, socket) do
      Moderator.set_for_topic(user_id, socket.topic)
      broadcast! socket, "moderator:set", %{
        moderator_id: user_id,
        timestamp: :os.system_time(:milli_seconds)
      }

    {:noreply, socket}
  end

  def handle_in("estimation:set", %{"issue_key" => issue_key, "estimation" => estimation}, socket) do
      Issue.set_estimation(issue_key, estimation)
      broadcast! socket, "estimation:set", %{
        issue_key: issue_key,
        estimation: estimation,
        timestamp: :os.system_time(:milli_seconds)
      }

      {:noreply, socket}
    end

  defp track_presence(socket) do
    push socket, "players_state", Presence.list(socket)
    Presence.track(socket, user_id(socket), user_data(socket))

    socket
  end

  defp determine_moderator(socket) do
    Presence.list(socket)
      |> Map.keys
      |> Moderator.determine_moderator(socket.topic)
      |> Moderator.set_for_topic(socket.topic)

    socket
  end

  defp send_current_moderator(socket) do
     broadcast! socket, "moderator:current", %{"moderator_id": Moderator.get_for_topic(socket.topic)}

     socket
  end

  defp send_current_issue(socket) do
     push socket, "issue:current", %{"issue_key": CurrentIssue.get_for_topic(socket.topic)}

     socket
  end

  defp send_current_votes(socket) do
     issue = CurrentIssue.get_for_topic(socket.topic)
     Issue.list_to_estimate
      |> Enum.map(&(&1.key))
      |> Enum.each(fn issue ->
       push socket, "vote:current", %{
        "issue_key" => issue,
        "votes" => Votes.for_topic_and_issue(socket.topic, issue)
       }
      end)

     socket
  end

  defp user_id(socket) do
    socket.assigns.user["id"]
  end

  defp user_data(socket, override \\ %{}) do
    Map.merge %{
      online_at: :os.system_time(:milli_seconds),
      user: socket.assigns.user,
      last_vote: nil,
    }, override
  end
end
