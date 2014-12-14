defmodule Abutment.UserModel do
  use Ecto.Model
  import Abutment.Validations

  schema "users" do
    field :email, :string
    field :name, :string
    field :crypted_password, :string
    has_many :created_tasks, Abutment.TaskModel, foriegn_key: :creator_id
    has_many :owned_tasks, Abutment.TaskModel, foriegn_key: :owner_id

    field :created_at, :datetime
    field :updated_at, :datetime
  end

  validate user,
    also: validate_name(),
    also: validate_email()

  validatep validate_email(user),
    email: present() and has_format(~r"^.+@.+\..+$"),
    also: unique([:email], on: Abutment.Repo)

  validatep validate_name(user),
    name: present()

  def create(name, email, password) do
    now = Ecto.DateTime.utc
    errors = []
    user = %__MODULE__{name: name, email: String.downcase(email), 
                       created_at: now, updated_at: now}

    if password do
      errors = validate_password(errors, password)
      user = %{user | crypted_password: crypt(password)}
    end

    errors = errors ++ validate(user)
    case errors do
      [] ->
        {:ok, Repo.insert(user)}
      errors ->
        {:error, errors}
    end
  end

  def update(user, name, email, password) do
    errors = []

    if email do
      user = %{user | email: String.downcase(email)}
      errors = errors ++ validate_email(user)
    end

    if password do
      errors = errors ++ validate_password(errors, password)
      user = %{user | crypted_password: crypt(password)}
    end

    if name do
      errors = errors ++ validate_name(user)
      user = %{user | name: name}
    end

    case errors do
      [] ->
        user = %{user | updated_at: Ecto.DateTime.utc}
        Abutment.Repo.update(user)
        {:ok, user}
      errors ->
        {:error, errors}
    end
  end

  def validate_password(errors, password) when is_nil(password) or (is_binary(password) and byte_size(password) == 0) do 
    errors ++ [{:password, "must be set"}]
  end
  def validate_password(errors, password) when byte_size(password) < 6 do
    errors ++ [{:password, "must be greater than 6 characters long"}]
  end
  def validate_password(errors, _password) do
    errors
  end

  def validate_unique_email(errors, user) do
    query = from u in __MODULE__,
      where: downcase(u.email) == downcase(^user.email),
      limit: 1

    case Abutment.Repo.all(query) do
      [] -> errors
      _users -> errors ++ [{:email, "must be unique"}]
    end
  end

  def fetch(email) do
    query = from u in __MODULE__,
      where: downcase(u.email) == downcase(^email),
      limit: 1
    case Abutment.Repo.all(query) do
      [user] -> user
      _err -> raise "Two users with the same email"
    end
  end

  def crypt(""), do: raise "You cannot encrypt an empty password."
  def crypt(password) do
    :erlpass.hash(password)
  end

  def password_check(_user, ""), do: false
  def password_check(nil, _password), do: false
  def password_check(%__MODULE__{:crypted_password => nil}, _password), do: false
  def password_check(%__MODULE__{:crypted_password=>crypted_password}, password) do
    :erlpass.match(password, crypted_password)
  end
end
