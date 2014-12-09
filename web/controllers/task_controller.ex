defmodule Abutment.TaskController do
  use Phoenix.Controller

  alias Abutment.TaskModel
  alias Abutment.Repo
  alias Abutment.Router
  import Ecto.Query

  plug Abutment.Authenticate
  plug :action

  # GET /tasks
  def index(conn, params) do
    params = clean_params(params)
    query = TaskModel.list(params)
    query2 = from t in query,
              limit: params["page_size"],
              offset: params["page"] * params["page_size"]
    tasks = Repo.all(query2)
    render conn, "index.json", params: params, tasks: tasks
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

  defp clean_params(params) do
   filter = Dict.get(params, "filter", %{}) |> Dict.take(["tags"])
   include = %{}
   sort = Dict.get(params, "sort", %{}) |> Dict.take(["created_at", "updated_at", "title"])
   page = Dict.get(params, "page", "0") |> String.to_integer
   page_size = Dict.get(params, "page_size", "20") |> String.to_integer
   %{"filter" => filter, "include" => include, "sort" => sort, "page" => page, "page_size" => page_size}
  end
end
