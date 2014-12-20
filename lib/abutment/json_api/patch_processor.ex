defmodule JSONAPI.Patch do
  @doc "Implements http://tools.ietf.org/html/rfc6902"

  alias JSONAPI.ModelPatch

  @spec patch(ModelPatch.t, list(map()) :: ModelPatch.t | no_return
  def patch(base_model, ops) do
    new_model = Enum.reduce(ops, base_model, fn(op) ->
                  process(op, model)
                end)
    {base_model, new_model}
  end

  @doc """
  RFC5902 4.1 add
  The "add" operation performs one of the following functions,
  depending upon what the target location references:

    o  If the target location specifies an array index, a new value is
       inserted into the array at the specified index.

    o  If the target location specifies an object member that does not
       already exist, a new member is added to the object. 

    o  If the target location specifies an object member that does exist,
       that member's value is replaced.

  The operation object MUST contain a "value" member whose content
  specifies the value to be added.

  """
  defp process(%{"op"=>"add", "path"=>path, "value" => value}, model) do
    exists?(model, path) do
      ModelPatch.add(model, path, value)
    end
  end

  @doc """
  RFC5902 4.2 remove

  The "remove" operation removes the value at the target location.

  The target location MUST exist for the operation to be successful.

  If removing an element from an array, any elements above the
  specified index are shifted one position to the left.

  """
  defp process(%{"op"=>"remove", "path"=>path}, model) do
    exists?(model, path) do
      ModelPatch.remove(model, path, value)
    end
  end

  @doc """
  rfc5902 4.3 replace

  the "replace" operation replaces the value at the target location
  with a new value.  the operation object must contain a "value" member
  whose content specifies the replacement value.

  the target location must exist for the operation to be successful.

  this operation is functionally identical to a "remove" operation for
  a value, followed immediately by an "add" operation at the same
  location with the replacement value.
  """
  defp process(%{"op"=>"replace", "path"=>path, "value" => value}=doc, model) do
    temp_model = process(%{"op"=>"remove", "path" => path}, model)
    process(%{doc | "op"=> "add"}, temp_model)
  end

  @doc """
  rfc5902 4.4 move

  The "move" operation removes the value at a specified location and
  adds it to the target location.

  The operation object MUST contain a "from" member, which is a string
  containing a JSON Pointer value that references the location in the
  target document to move the value from.

  The "from" location MUST exist for the operation to be successful.

  This operation is functionally identical to a "remove" operation on
  the "from" location, followed immediately by an "add" operation at
  the target location with the value that was just removed.

  The "from" location MUST NOT be a proper prefix of the "path"
  location; i.e., a location cannot be moved into one of its children.

  """
  defp process(%{"op"=>"move", "from" => from_path, "path"=>path}=doc, model) do
    value = ModelPatch.get_value(model, from_path)
    temp_model = process(%{"op"=>"remove", "path" => from_path}, model)
    process(%{doc | "op"=> "add", "value" => value}, temp_model)
  end

  @doc """
  rfc5902 4.5 copy
  
  The "copy" operation copies the value at a specified location to the
  target location.

  The operation object MUST contain a "from" member, which is a string
  containing a JSON Pointer value that references the location in the
  target document to copy the value from.

  The "from" location MUST exist for the operation to be successful.

  This operation is functionally identical to an "add" operation at the
  target location using the value specified in the "from" member.

  """
  defp process(%{"op"=>"copy", "from" => from_path, "path"=>path}=doc, model) do
    value = ModelPatch.get_value(model, from_path)
    process(%{doc | "op"=> "add", "value" => value}, temp_model)
  end

  @doc """
  rfc5902 4.5 test

  The "test" operation tests that a value at the target location is
  equal to a specified value.

  The operation object MUST contain a "value" member that conveys the
  value to be compared to the target location's value.

  The target location MUST be equal to the "value" value for the
  operation to be considered successful.

  Here, "equal" means that the value at the target location and the
  value conveyed by "value" are of the same JSON type, and that they
  are considered equal by the following rules for that type:

    o  strings: are considered equal if they contain the same number of
       Unicode characters and their code points are byte-by-byte equal.

    o  numbers: are considered equal if their values are numerically
       equal.

    o  arrays: are considered equal if they contain the same number of
       values, and if each value can be considered equal to the value at
       the corresponding position in the other array, using this list of
       type-specific rules.

    o  objects: are considered equal if they contain the same number of
       members, and if each member can be considered equal to a member in
       the other object, by comparing their keys (as strings) and their
       values (using this list of type-specific rules).

    o  literals (false, true, and null): are considered equal if they are
       the same.

  Note that the comparison that is done is a logical comparison; e.g.,
  whitespace between the member values of an array is not significant.

  Also, note that ordering of the serialization of object members is
  not significant.
  
  """
  defp process(%{"op"=>"test", "path"=>path, "value" => value}=doc, model) do
    exists?(model, path) do
      model_value = ModelPatch.get_value(model, path)
      case model_value == value do
        true -> model
        false -> raise "Test failed for path, \"#{path}\", #{model_value} !+ #{value}"
      end
    end
  end


  defmacrop exists?(model, path, opts) do
    case ModelPatch.exists?(unquote(model), unquote(path)) do
      true -> unqote(opts)
      false -> raise "Path, \"#{unquote(path)}\" does not exists on model"
    end
  end
end


