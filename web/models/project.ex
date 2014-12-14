defmodule Abutment.ProjectModel do
  use Ecto.Model
  import Ecto.Query
  alias Abutment.Repo
  alias Abutment.ProjectUsers

  schema "projects" do
    field :name, :string
    belongs_to :owner, Abutment.UserModel, foriegn_key: :owner_id
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
        case Repo.all(get_one(project.id)) do
          [project] -> {:ok, project}
          _ -> raise "Project didn't return after being created"
        end
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
        case Repo.all(get_one(project.id)) do
          [project] -> {:ok, project}
          _ -> raise "Project didn't return after being created"
        end
      errors -> {:error, errors}
    end
  end

  def get_one(project_id) when is_binary(project_id) do
    String.to_integer(project_id) |> get_one
  end
  def get_one(project_id) when is_integer(project_id) do
    from(p in Abutment.ProjectModel,
          preload: [:owner, project_users: [:user]],
          where: p.id == ^project_id)
  end
end
