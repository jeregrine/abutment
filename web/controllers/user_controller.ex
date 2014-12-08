defmodule Abutment.UserController do
  use Phoenix.Controller

  alias Abutment.TaskModel
  alias Abutment.Repo
  alias Abutment.Router
  import Ecto.Query

  plug :action

  # GET /tasks/:id
  def show(conn, %{"id" => id}) do
    case Repo.get(UserModel, String.to_integer(id)) do
     nil -> put_status(conn, :not_found) |> render "404.json"
     user -> render conn, "show.json", user: user
    end
  end

  # POST /users
  def create(conn, json=%{"format" => "json"}) do
    password = Dict.get(json, "password", nil),
    user = %UserModel{
      name: Dict.get(json, "name", nil),
      email: Dict.get(json, "email", nil),
    }
    case UserModel.validate(user) |> UserModel.validate_password(password) do
      [] -> 
        user = %{user | crypted_password: UserModel.crypt(user.password), password: nil}
        user = Repo.insert(user)
        conn 
          |> put_resp_header("Location", Router.Helpers.user_path(:show, user.id))
          |> put_status(201)
          |> render "show.json", user: user
      errors ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # PUT/PATCH /tasks/:id
  def update(_conn, %{"id": _id}) do
  end

  # DELETE /tasks/:id
  def destroy(_conn, %{"id": _id}) do
  end
end
