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
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Estimator.Web do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :index
  end

  scope "/auth", Estimator.Web do
      pipe_through [:browser, :browser_auth]

      get "/:identity", AuthController, :login
      get "/:identity/callback", AuthController, :callback
      post "/:identity/callback", AuthController, :callback
      delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Estimator.Web do
  #   pipe_through :api
  # end
end
