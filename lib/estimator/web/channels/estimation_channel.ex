defmodule Estimator.Web.EstimationChannel do
  use Estimator.Web, :channel

  alias Estimator.Web.Presence
  alias Estimator.{
    Moderator,
    Votes,
    Vote.Vote,
    Issue.CurrentIssue,
    Web.VoteView,
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
      |> send_current_moderator
      |> send_current_issue

    {:noreply, socket}
  end

  def handle_in("vote:new", message, socket) do
    {:ok, vote} = Votes.insert_vote(%{
       topic: socket.topic,
       user_id: socket.assigns.user["id"],
       issue_key: message["issue_key"],
       vote: message["vote"],
    })

    IO.inspect vote
    broadcast! socket, "vote:new", VoteView.render("vote.json", vote)

    {:noreply, socket}
  end

  def handle_in("issue:set", message, socket) do
    CurrentIssue.set_for_topic(socket.topic, message["issue_key"])
    broadcast! socket, "issue:set", %{ issue_key: message["issue_key"] }

    {:noreply, socket}
  end

  def handle_in("moderator:set", user_id, socket) do
      Moderator.set_for_topic(socket.topic, user_id)
      broadcast! socket, "moderator:set", %{
        moderator_id: user_id,
        timestamp: :os.system_time(:milli_seconds)
      }

    {:noreply, socket}
  end

  def handle_in("estimation:set", %{"issue_key" => issue_key, "estimation" => estimation}, socket) do
#      Issue.set_estimation(issue_key, estimation);
#      broadcast! socket, "estimation:set", %{
#        issue_id: user_id,
#        estimation: estimation,
#        timestamp: :os.system_time(:milli_seconds)
#      }

      {:noreply, socket}
    end

  defp track_presence(socket) do
    push socket, "players_state", Presence.list(socket)
    Presence.track(socket, user_id(socket), user_data(socket))

    socket
  end

  defp send_current_moderator(socket) do
     push socket, "moderator:current", %{"moderator_id": Moderator.get_for_topic(socket.topic)}

     socket
  end

  defp send_current_issue(socket) do
     push socket, "issue:current", %{"issue_key": CurrentIssue.get_for_topic(socket.topic)}

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
