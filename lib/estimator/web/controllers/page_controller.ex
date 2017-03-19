defmodule Estimator.Web.PageController do
  use Estimator.Web, :controller

  alias Estimator.Api.Jira

  plug Ueberauth

  def login(conn, _params) do
    render conn, current_user: get_session(conn, :current_user)
  end

  def estimate(conn, _params) do
    render conn, current_user: get_session(conn, :current_user)
  end

  def estimated(conn, _params) do
    render conn, current_user: get_session(conn, :current_user)
  end

  def backlog(conn, _params) do
    backlog = Jira.backlog(1)

    render conn, backlog: backlog, current_user: get_session(conn, :current_user)
  end

  def select_issue(conn, %{"key" => key}) do
#    backlog = Jira.backlog(1)
    success(conn, "Issue selected", page_path(conn, :backlog))
  end


  def unauthenticated(conn, _) do
      conn
#      |> Plug.Conn.send_resp(401, "Unauthenticated. Access? Nope.")
      |> redirect(to: "/login")
  end

 # ---

  defp success(conn, message, redirect_path) do
    msg(conn, :success, message, redirect_path)
  end

  defp msg(conn, type, message, redirect_path) do
      conn
      |> put_flash(type, message)
      |> redirect(to: redirect_path)
    end
end
