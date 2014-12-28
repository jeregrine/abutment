defmodule Abutment.ProjectModel do
  use Ecto.Model
  import Ecto.Query
  alias Abutment.Repo
  alias Abutment.ProjectUsers

  schema "projects" do
    field :name, :string
    belongs_to :owner, Abutment.UserModel, foreign_key: :owner_id
    has_many :project_users, ProjectUsers, foreign_key: :project_id
    field :created_at, :datetime
    field :updated_at, :datetime
  end

  validate task,
    name: present()

  def create(name, owner) do
    project = %__MODULE__{
      name: name,
      owner: owner
    }

    case validate(project) do
      [] ->
        project = Repo.insert(project)
        {:ok, _} = ProjectUsers.add_user_to_project(owner, project, "owner")
        {:ok, project}
      errors -> {:error, errors}
    end
  end

  def update(project, name) do
    if name do
      project = %{project | name: name}
    end

    project = %{project | updated_at: Ecto.DateTime.utc}
    case validate(project) do
      [] ->
        Repo.update(project)
        {:ok, project}
      errors ->
        {:error, errors}
    end
  end

  def get(id) do
    query = from p in __MODULE__,
      where: p.id == ^id,
      limit: 1
    case Abutment.Repo.all(query) do
      [project] -> {:ok, project}
      [] -> {}
      _err -> raise "Two projects with the same id"
    end
  end
end
