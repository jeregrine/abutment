defmodule Abutment.Repo.Migrations.AddProjects do
  use Ecto.Migration

  def up do
    ["""
    CREATE TABLE projects(
      id serial primary key,
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp
      name text,
      FOREIGN KEY (creator_id) REFERENCES users(id)
    )
    """,
    """
    CREATE TABLE projects_users(
      id serial primary_key,
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp,
      role text DEFAULT 'user',
      FOREIGN KEY (project_id) REFERENCES projects(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """,
    "ALTER TABLE tasks ADD COLUMN project_id integer",
    "ALTER TABLE tasks ADD FOREIGN KEY (project_id) REFERENCES projects(id)"]
  end

  def down do
    ["DROP TABLE projects",
     "DROP TABLE projects_users",
     "ALTER TABLE tasks DROP COLUMN project_id"]
  end
end
