defmodule Abutment.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
    plug Abutment.JSONAPIResponse
  end

  scope "/", Abutment do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

   scope "/api", Abutment do
     pipe_through :api
     get "/sessions", SessionController, :index
     post "/sessions", SessionController, :create
     delete "/sessions", SessionController, :destroy

     resources "tasks", TaskController, only: [:index, :show, :create, :update, :destroy]
     resources "users", UserController, only: [:index, :show, :create, :update, :destroy]
     resources "projects", ProjectController, only: [:show, :create, :update, :destroy]
   end
end
