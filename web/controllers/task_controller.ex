defmodule Abutment.TaskController do
  use Phoenix.Controller

  alias Abutment.TaskModel
  alias Abutment.Repo
  alias Abutment.Router

  plug :action

  # GET /tasks
  def index(_conn, _params) do

  end

  # GET /tasks/:id
  def show(conn, %{"id" => id}) do
    case Repo.get(TaskModel, String.to_integer(id)) do
     nil -> put_status(conn, :not_found) |> render "404.json"
     task -> render conn, "show.json", task: task
    end
  end

  # POST /tasks
  def create(conn, json=%{"format" => "json"}) do
    task = %TaskModel{
      title: Dict.get(json, "title", nil),
      body: Dict.get(json, "body", ""),
      tags: TaskModel.cleanup_tags(Dict.get(json, "tags", []))
    }
    case TaskModel.validate(task) do
      [] -> 
        task = Repo.insert(task)
        conn 
          |> put_resp_header("Location", Router.Helpers.task_path(:show, task.id))
          |> put_status(201)
          |> render "show.json", task: task
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
