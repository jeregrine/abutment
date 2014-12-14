defmodule Abutment.UserController do
  use Phoenix.Controller

  alias Abutment.UserModel
  alias Abutment.Repo
  alias Abutment.Router

  plug Abutment.Authenticate when action in [:show, :update, :destroy]
  plug :action

  # GET /user/:id
  def show(conn, %{"id" => id}) do
    case Repo.get(Abutment.UserModel, String.to_integer(id)) do
     nil -> put_status(conn, :not_found) |> render "404.json"
     user -> render conn, "show.json", user: user
    end
  end

  # POST /users
  def create(conn, json=%{"format" => "json"}) do
    user_json = Dict.get(json, "users", %{})

    password = Dict.get(user_json, "password", nil)
    name = Dict.get(user_json, "name", nil)
    email = Dict.get(user_json, "email", nil)
    case UserModel.create(name, email, password) do
      {:ok, user} -> 
        conn 
          |> put_resp_header("Location", Router.Helpers.user_path(:show, user.id))
          |> put_status(201)
          |> Abutment.Authenticate.login(user)
          |> render "show.json", user: user
      {:error, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # PUT/PATCH /users/:id
  def update(conn, json=%{"format" => "json"}) do
    user_json = Dict.get(json, "users", %{})

    can_change?(conn, Dict.get(user_json, "id", nil))

    current_user = conn.assigns[:current_user]
    password = Dict.get(user_json, "password", nil)
    email = Dict.get(user_json, "email", nil)
    name = Dict.get(user_json, "name", nil)

    case UserModel.update(current_user, name, email, password) do
      {:ok, user} ->
        conn 
          |> put_status(200)
          |> render "show.json", user: user
      {:error, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # DELETE /users/:id
  def destroy(conn, %{"id": id}) do
    can_change?(conn, id)
    current_user = conn.assigns[:current_user]
    Repo.delete(current_user)
    resp(204, "") |> send_resp
  end

  defp can_change?(conn, id) when is_binary(id) do
    can_change?(conn, String.to_integer(id))
  end
  defp can_change?(conn, id) do
    #TODO Define Security Model
    current_user = conn.assigns[:current_user]
    if current_user.id != id do
      put_status(conn, 401) |> render "401.json" |> halt
    end
  end
end
