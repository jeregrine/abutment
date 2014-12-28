defmodule Abutment.ProjectController do
  use Phoenix.Controller

  alias Abutment.ProjectModel
  alias Abutment.Repo
  alias Abutment.Router
  import Ecto.Query

  plug Abutment.Authenticate
  plug :action

  # GET /projects
  def index(conn, params) do
    params = clean_params(params)
    query = ProjectModel.list(params)
    query2 = from t in query,
              limit: params["page_size"],
              offset: params["page"] * params["page_size"]

    projects = Repo.all(query2)
    render conn, "index.json", params: params, projects: projects
  end

  # GET /projects/:id
  def show(conn, %{"id" => id}) do
    project = fetch(conn, id)
    render conn, "show.json", project: project
  end

  # POST /projects
  def create(conn, json=%{"format" => "json"}) do
    current_user = conn.assigns[:current_user]
    project_json = Dict.get(json, "projects", %{})

    name = Dict.get(project_json, "name", nil)
    links = Dict.get(project_json, "links", %{})

    owner = current_user

    case ProjectModel.create(name, owner) do
      {:ok, project} ->
        conn
          |> put_resp_header("Location", Router.Helpers.project_path(:show, project.id))
          |> put_status(201)
          |> render "show.json", project: project
      {:errors, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # PUT/PATCH /projects/:id
  def update(conn, json=%{"format" => "json"}) do
    project_json = Dict.get(json, "projects", %{})

    project = fetch(conn, Dict.get(project_json, "id", nil))
    can_change?(conn, project)

    name = Dict.get(project_json, "name", nil)

    case ProjectModel.update(project, name) do
      {:ok, project} ->
        conn 
          |> put_status(200)
          |> render "show.json", project: project
      {:error, errors} ->
        put_status(conn, 400) |> render "errors.json", errors: errors
    end
  end

  # DELETE /projects/:id
  def destroy(conn, %{"id" => id}) do
    project = fetch(conn, id)
    can_change?(conn, project)
    Repo.delete(project)
    resp(conn, 204, "") |> send_resp
  end

  # TODO Fix the %{} instead of []
  defp clean_params(params) do
   filter = Dict.get(params, "filter", %{}) |> Dict.take(["owner_id"])
   include = Dict.get(params, "include", %{}) |> Dict.take([])
   sort = Dict.get(params, "sort", %{}) |> Dict.take(["created_at", "updated_at", "name"])
   page = Dict.get(params, "page", "0") |> String.to_integer
   page_size = Dict.get(params, "page_size", "20") |> String.to_integer

   %{"filter" => filter, "include" => include, "sort" => sort, "page" => page, "page_size" => page_size}
  end

  defp fetch(conn, id) do
    query = from p in Abutment.ProjectModel,
            where: p.id == ^String.to_integer(id),
            preload: :owner,
            limit: 1
    case Repo.all(query) do
      [] -> put_status(conn, :not_found) |> render "404.json"
      [project] -> project
    end
  end

  defp can_change?(conn, project) do
    current_user = conn.assigns[:current_user]
    if current_user.id != project.owner_id do
      put_status(conn, 401) |> render "401.json" |> halt
    end
  end
end
