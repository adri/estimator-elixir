defmodule Estimator.Web.EstimationChannel do
  use Estimator.Web, :channel

  alias Estimator.Web.Presence

  def join("estimation:ticketswap", _params, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def join(_other, _params, socket) do
    {:error, "No estimation"}
  end

  def handle_info(:after_join, socket) do
    push socket, "players_state", Presence.list(socket)

    Presence.track(socket, user_id(socket), user_data(socket))

    {:noreply, socket}
  end

  def handle_in("vote:new", message, socket) do
     Presence.update(socket, user_id(socket), user_data(socket, %{
       last_vote: message,
     }))

    {:noreply, socket}
  end

  def handle_in("moderator:set", message, socket) do
      broadcast! socket, "moderator:set", %{
        user: socket.assigns.user,
        moderatorId: message,
        timestamp: :os.system_time(:milli_seconds)
      }

    {:noreply, socket}
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
