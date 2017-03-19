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

    Presence.track(socket, socket.assigns.user, %{
      online_at: :os.system_time(:milli_seconds),
      last_vote: nil,
    })

    {:noreply, socket}
  end

  def handle_in("vote:new", message, socket) do
     Presence.update(socket, socket.assigns.user, %{
       last_vote: message,
       online_at: :os.system_time(:milli_seconds),
     })

    {:noreply, socket}
  end
end
