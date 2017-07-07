defmodule MoroxiteServer.Providers.Reddit.FetcherTest do
  use ExUnit.Case, async: true
  doctest MoroxiteServer.Providers.Reddit.Fetcher
  alias MoroxiteServer.Providers.Reddit.Fetcher

  @moduledoc """
  Tests for the Reddit fetcher
  """

  test "build_link returns a valid link to reddit" do
    assert Fetcher.build_link("test", "top") ==
      "https://www.reddit.com/r/test/top.json"
  end

  test "build_link listing_type defaults to hot" do
    assert Fetcher.build_link("test") ==
      "https://www.reddit.com/r/test/hot.json"
  end

  test "build_link should fail if you try to give it incorrect listing" do
    catch_error Fetcher.build_link("test", "invalid")
  end

  test "build_map returns map when given correct link" do
    map = "test"
          |> Fetcher.build_link()
          |> Fetcher.build_map()
    assert (map["kind"] == "Listing")
  end

  test "filter_over_18 should remove inapropriate posts" do
    {:ok, json} = File.read("test/data/eveporn.json")
    {:ok, map}  = Poison.decode(json)

    result = Fetcher.filter_over_18(map)
    refute Enum.any?(get_in(result, ["data", "children"]),
                     &(get_in(&1, ["data", "over_18"])))
  end

  test "fetch will return tuple of provider name and result urls" do
    {name, result} = Fetcher.fetch("test")
    assert name == "Reddit" && is_list(result)
  end
end
