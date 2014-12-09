defmodule Abutment.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
  end

  scope "/", Abutment do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

   scope "/api", Abutment do
     pipe_through :api
     resources "tasks", TaskController, only: [:index, :show, :create, :update, :destroy]
     resources "users", UserController, only: [:index, :show, :create, :update, :destroy]
     resources "session", SessionController, only: [:index, :create, :destroy]
   end
end
