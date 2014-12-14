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
    task = fetch(conn, id)
    render conn, "show.json", task: task
  end

  # POST /tasks
  def create(conn, json=%{"format" => "json"}) do
    current_user = conn.assigns[:current_user]
    task_json = Dict.get(json, "tasks", %{})

    title = Dict.get(task_json, "title", nil)
    body = Dict.get(task_json, "body", "")
    tags = Dict.get(task_json, "tags", [])
    links = Dict.get(task_json, "links", %{})
    owner_id = Dict.get(links, "creator_id", current_user.id)

    creator_id = current_user.id

    case TaskModel.create(title, body, tags, creator_id, owner_id) do
      {:ok, task} ->
        conn 
          |> put_resp_header("Location", Router.Helpers.task_path(:show, task.id))
          |> put_status(201)
          |> render "show.json", task: task
      {:error, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # PUT/PATCH /tasks/:id
  def update(conn, json=%{"format" => "json"}) do
    task_json = Dict.get(json, "tasks", %{})

    task = fetch(conn, Dict.get(task_json, "id", nil))
    can_change?(conn, task)

    title = Dict.get(task_json, "title", nil)
    body =  Dict.get(task_json, "body", nil)
    tags =  Dict.get(task_json, "tags", nil)
    links = Dict.get(task_json, "links", %{})
    owner_id = Dict.get(links, "creator_id", nil)

    case TaskModel.update(task, title, body, tags, owner_id) do
      {:ok, task} ->
        conn |> put_status(200) |> render "show.json", task: task
      {:error, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # DELETE /tasks/:id
  def destroy(conn, %{"id" => id}) do
    task = fetch(conn, id)
    Repo.delete(task)
    render conn, "show.json", task: task
  end

  # TODO Fix the %{} instead of []
  defp clean_params(params) do
   filter = Dict.get(params, "filter", %{}) |> Dict.take(["tags"])
   include = Dict.get(params, "include", %{}) |> Dict.take([])
   sort = Dict.get(params, "sort", %{}) |> Dict.take(["created_at", "updated_at", "title"])
   page = Dict.get(params, "page", "0") |> String.to_integer
   page_size = Dict.get(params, "page_size", "20") |> String.to_integer

   %{"filter" => filter, "include" => include, "sort" => sort, "page" => page, "page_size" => page_size}
  end

  defp can_change?(conn, task) do
    current_user = conn.assigns[:current_user]
    if current_user.id != task.owner_id or current_user.id != task.creator_id do
      put_status(conn, 401) |> render "401.json" |> halt
    end
  end

  defp fetch(conn, id) do
    query = from t in Abutment.TaskModel,
            where: t.id == ^String.to_integer(id),
            limit: 1,
            preload: [:creator, :owner]
    case Repo.all(query) do
      [] -> put_status(conn, :not_found) |> render "404.json"
      [task] -> task
    end
  end
end
