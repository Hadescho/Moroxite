defmodule MoroxiteServer.Providers.Reddit.Fetcher do
  @moduledoc """
  This module is going to download the json from the reddit api and parse it
  """

  @valid_listings ["new", "hot", "rising", "top", "controversial"]

  @doc """
  Build the link based on a ```reddit_name```

  `listing_type` is the way the items will be ordered. Defaults to `"hot"`
  """
  def build_link(reddit_name, listing_type \\ "hot")
  def build_link(reddit_name, listing_type)
    when listing_type in @valid_listings do

    "https://www.reddit.com/r/#{reddit_name}/#{listing_type}.json"
  end

  @doc """
  Build a map based on the json downloaded from ```link```

  `link` should be a string containing link to reddit json listing
  """
  def get_map(link) do
    case get_json(link) do
      {:ok, body} ->
        {:ok, map} = Poison.decode(body)
        map
    end
  end

  @doc """
  Downloads the json given on ```link```

  `link` should be a string containing link to reddit json listing
  """
  def get_json(link) do
    case HTTPoison.get(link) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: code}} -> {:remote_error, code}
      {:error, %HTTPoison.Error{reason: reason}} -> {:local_error, reason}
    end
  end

  @doc """
  Removes all listing entities marked as content for users over 18 y/o.

  `map` is a map structured as the json recieved from a reddit json listing
  """
  def filter_over_18(map) do
    list = map["data"]["children"]
    list = Enum.filter(list, &(!&1["data"]["over_18"]))
    put_in(map["data"]["children"], list)
  end

  @doc """
  Build a valid, in terms of the protocol, list of images and metadata

  `map` is a map structured as the json recieved from a reddit json listing
  """
  def build_list(map) do
    list = map
           |> get_in(["data", "children"])
           |> Enum.filter(&(get_in(&1, ["data", "preview", "enabled"])))
    result = list
             |> Enum.map(&parse_element/1)
             |> List.flatten
  end

  @doc """
  Build a valid map, in terms of the protocol, from a map based on the reddit
  structure

  `element` is a element of the "children" array of reddit listing
  """
  def parse_element(element) do
    source_reddit = element["data"]["subreddit_name_prefixed"]
    author = element["data"]["author"]
    tags = [source_reddit, author]
    sources = element
              |> get_in(["data", "preview", "images"])
              |> Enum.map(&(get_in(&1, ["source"])))
    Enum.map(sources, &(%{tags: tags,
                          url: &1["url"],
                          size: {(&1["width"]), &1["height"]}}))
  end
end
