defmodule MoroxiteServer.Downloader do
  use GenServer
  require Logger
  alias MoroxiteServer.DownloadTaskSupervisor, as: DownloadSupervisor
  @moduledoc """
  This module is responsble for providing an interface for downloading images
  from the interwebz
  """

  @doc """
  Starts the Downloaded
  """
  def start_link do
    GenServer.start(__MODULE__, :ok, name: MoroxiteServer.Downloader)
  end

  ### Client API

  # Start a task for downloading the image
  #   Download the image in memory
  #   Write it in file
  # When you recieve the a message with the task that the download was
  # completed return a message to the caller for success
  @doc """
  Download the image on the given `url` and save it in given `path`
  Should return :download_started.
  When the download is compleated:
    * If it was successful, it will return the following message
      {:success, url, path}
    * If it was unsuccessful, it will return
      {:failure, url, path}
  """
  def download_image(url, path) do
    GenServer.call(MoroxiteServer.Downloader, {:download, url, path})
  end

  ### Server Callbacks

  def init(:ok), do: {:ok, %{}}

  def handle_call({:download, url, path}, from, state) do
    task = Task.Supervisor.async_nolink(DownloadSupervisor,
                                        fn -> download_and_save(url, path) end)
    {:reply,
      :download_started,
      Map.merge(state, %{task.ref => {from, url, path}})
    }
  end

  def handle_info({ref, :ok}, state) do
    {{from, url, path}, new_state} = Map.pop(state, ref)

    {pid, _} = from
    send(pid, {:success, url, path})
    {:noreply, new_state}
  end
  def handle_info({ref, _}, state) do
    {{from, url, path}, new_state} = Map.pop(state, ref)
    send(from, {:failure, url, path})
    {:noreply, new_state}
  end
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    {:noreply, state}
  end
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {{from, url, path}, new_state} = Map.pop(state, ref)
    send(from, {:failure, url, path})
    {:noreply, new_state}
  end

  @doc """
  Downloads the image on `url` and save it to the given path.

  If the operation is successfull, return :ok
  If `url` isn't a url to an image return a :not_image
  If the write fails, return whatever error File.write returns
  """
  def download_and_save(url, path) do
    case download(url) do
      :not_image ->
        Logger.info("The content on #{url} is not an image")
        :not_image
      :error ->
        Logger.info("Encountered an error while trying to download from #{url}")
        :error
      image ->
        File.write(path, image, [:binary, :write])
    end
  end

  @doc """
  Downloads the image on `url`

  If the response from the `url` doesn't contain image return error.
  For now the implementation won't use "Accepts" header since I'm not sure if
  all webservers will respond correctly if given Accepts with only image MIMEs
  """
  def download(url) do
    url
  end
end
