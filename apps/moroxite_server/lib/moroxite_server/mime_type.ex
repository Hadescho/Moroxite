defmodule MoroxiteServer.MimeType do
  @moduledoc """
  Helper functions to deal with mime types in the application
  """

  @doc """
  Check if the given `mimetype` is mimetype for image
  """
  def image?(mimetype), do: Regex.match?(~r/\Aimage\/.*/, mimetype)

  @doc """
  Extract the file extension from mimetype
  """
  def extract_extension(mimetype) do
    ~r/.*\/(.*)/ # "something/(the captured substring)"
    |> Regex.run(mimetype)
    |> Enum.at(1)
  end
end
