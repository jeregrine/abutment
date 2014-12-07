defmodule Abutment.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", Abutment do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

   scope "/api", Abutment do
     pipe_through :api
     resources "tasks", TaskController, only: [:index, :show, :create, :update, :destroy]
   end
end
