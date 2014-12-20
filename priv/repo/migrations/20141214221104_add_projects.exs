defmodule Abutment.Repo.Migrations.AddProjects do
  use Ecto.Migration

  def up do
    ["""
    CREATE TABLE projects(
      id serial primary key,
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp,
      name text,
      owner_id integer REFERENCES users(id)
    )
    """,
    """
    CREATE TABLE projects_users(
      id serial primary key,
      created_at timestamp DEFAULT current_timestamp,
      updated_at timestamp DEFAULT current_timestamp,
      role text DEFAULT 'user',
      project_id integer REFERENCES projects(id),
      user_id integer REFERENCES users(id)
    )
    """,
    "ALTER TABLE tasks ADD COLUMN project_id integer REFERENCES projects"]
  end

  def down do
    ["DROP TABLE projects_users",
     "ALTER TABLE tasks DROP COLUMN project_id",
     "DROP TABLE projects"]
  end
end
