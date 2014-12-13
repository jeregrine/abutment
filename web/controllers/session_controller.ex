defmodule Abutment.SessionController do
  use Phoenix.Controller

  alias Abutment.UserModel
  alias Abutment.Router
  alias Abutment.Authenticate

  plug Abutment.Authenticate when action in [:index, :destroy]
  plug :action

  # GET /session
  def index(conn, _params) do
    render conn, "show.json", user: conn.assigns[:current_user]
  end

  # POST /users
  def create(conn, json=%{"format" => "json"}) do
    password = Dict.get(json, "password", nil)
    email = Dict.get(json, "email", nil)

    # Find User
    case UserModel.fetch(email) do
     nil -> put_status(conn, 400) |> render "errors.json"
     user -> case UserModel.password_check(user, password) do # Check Password
       true ->  put_resp_header(conn, "Location", Router.Helpers.session_path(:index))
                |> Authenticate.login(user)
                |> put_status(201)
                |> render "show.json", user: user
       false -> put_status(conn, 400) |> render "errors.json"
     end
    end
  end

  # DELETE /tasks
  def destroy(conn, _params) do
    user = conn.assigns[:current_user]
    conn = Authenticate.logout(conn)
    render conn, "show.json", user: user
  end
end
