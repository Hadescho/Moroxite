defmodule MoroxiteServer.MimeTypeTest do
  use ExUnit.Case, async: true
  doctest MoroxiteServer.MimeType
  alias MoroxiteServer.MimeType

  @moduledoc """
  Test for the MimeType helper module
  """

  test "image? return true when given image mimetype" do
    assert MimeType.image?("image/jpeg")
    assert MimeType.image?("image/png")
    refute MimeType.image?("application/json")
    refute MimeType.image?("")
  end

  @tag :todo
  test "image? should check the actual existance of the mimetype" do
    refute MimeType.image?("image/jpg")
  end

  test "extract_extension should return the correct extension" do
    assert MimeType.extract_extension("image/png") == "png"
    assert MimeType.extract_extension("image/jpeg") == "jpeg"
  end
end
