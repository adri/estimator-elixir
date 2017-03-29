defmodule Estimator.Web.Router do
  use Estimator.Web, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
#    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: Estimator.Web.PageController
  end

  scope "/login", Estimator.Web do
    pipe_through [:browser]

    get "/", PageController, :login
  end

  scope "/", Estimator.Web do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :backlog
    get "/backlog", PageController, :backlog
    get "/backlog/refresh", PageController, :backlog_refresh
    get "/estimate", PageController, :estimate
    get "/estimated", PageController, :estimated
    get "/issues/:issue_key/deselect", PageController, :deselect_issue
    post "/issues/select", PageController, :select_issues
  end

  scope "/auth", Estimator.Web do
      pipe_through [:browser]

      get "/:identity", AuthController, :login
      get "/:identity/callback", AuthController, :callback
      post "/:identity/callback", AuthController, :callback
      delete "/logout", AuthController, :delete
  end
end
