defmodule Abutment.ProjectUsers do
  use Ecto.Model
  import Ecto.Query
  alias Abutment.Repo

  schema "projects_users" do
    field :role, :string
    belongs_to :user, Abutment.UserModel, foreign_key: :user_id
    belongs_to :project, Abutment.ProjectModel, foreign_key: :project_id
    field :created_at, :datetime
    field :updated_at, :datetime
  end

  def remove_user_from_project(user, project) do
    from(p_u in __MODULE__, 
         where: p_u.user_id == ^user.id and p_u.project_id == ^project.id,
         limit: 1)
      |> Repo.delete_all
  end

  def add_user_to_project(user, project, role) do
    query = from p_u in __MODULE__, 
            where: p_u.user_id == ^user.id and p_u.project_id == ^project.id,
            limit: 1
    case Repo.all(query) do
      [] -> create_project_user(user, project, role)
      [p_user] -> update_role(p_user, role)
    end
  end

  defp update_role(p_user=%{:role => current_role}, role) when current_role == role do
    {:ok, p_user}
  end
  defp update_role(p_user, role) when role in ["user", "owner"] do
    p_user = %{p_user | role: role, updated_at: Ecto.DateTime.utc}

    {Repo.update(p_user), p_user}
  end

  defp create_project_user(user, project, role) do
    p_user = %__MODULE__{
      role: role,
      user: user,
      project: project
    }

    case Repo.insert(p_user) do
      nil -> {:error, nil}
      p_user -> {:ok, p_user}
    end
  end
end
