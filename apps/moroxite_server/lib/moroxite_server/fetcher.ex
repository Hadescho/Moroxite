defmodule Fetcher do
  @moduledoc """
  Behaviour definition for fetchers
  """
  @callback fetch(String.t) :: {provider_name :: String.t,
                                results       :: %{tags: [String.t],
                                                   url: String.t,
                                                   size: {integer, integer}}}
end
