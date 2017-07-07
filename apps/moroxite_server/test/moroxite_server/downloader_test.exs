defmodule MoroxiteServer.DownloaderTest do
  alias ExVCR.{Config, Mock}
  alias MoroxiteServer.Downloader

  use ExUnit.Case, async: true
  use Mock, adapter: ExVCR.Adapter.Hackney

  import ExUnit.CaptureLog

  @moduledoc """
  These are tests for the Downloader module of the project
  """

  @images_dir "test/data/images"
  @cassette_dir "fixture/vcr_cassettes"
  @sleep_time 100
  @correct_url "http://via.placeholder.com/100x100"
  @incorrect_url "http://example.com"

  setup_all do
    unless File.dir?(@cassette_dir), do: File.mkdir(@cassette_dir)
    Config.cassette_library_dir(@cassette_dir)
    :ok
  end

  setup do
    unless File.dir?(@images_dir), do: File.mkdir(@images_dir)
    on_exit fn ->
      File.rm_rf(@images_dir)
    end
  end

  test "download_image returns correct tuple if `url` is a correct link" do
    use_cassette "downloader_correct" do
      response = Downloader.download_image(@correct_url, @images_dir)
      Process.sleep(@sleep_time)
      assert_receive {:success, @correct_url, @images_dir}
    end
  end

  test "download_image downloads image in `url` if given correct link" do
    use_cassette "downloader_correct" do
      Downloader.download_image(@correct_url, @images_dir)

      Process.sleep(@sleep_time)
      assert 1 == @images_dir
                  |> File.ls!
                  |> length
    end
  end

  test "download_image send failure message if the download failed" do
    use_cassette "downloader_incorrect" do
      response = Downloader.download_image(@incorrect_url, @images_dir)
      Process.sleep(@sleep_time)
      assert_receive {:failure, @incorrect_url, @images_dir}
    end
  end

  test "download_image doesn't download image if `url` is incorrect" do
    use_cassette "downloader_incorrect" do
      Downloader.download_image(@incorrect_url, @images_dir)

      Process.sleep(@sleep_time)
      assert 0 == @images_dir
                  |> File.ls!
                  |> length
    end
  end

  test "download_image logs a message if `url` isn't a link to image" do
    use_cassette "downloader_incorrect" do
      func = fn ->
        Downloader.download_image(@incorrect_url, @images_dir)
        Process.sleep(@sleep_time)
      end

      assert capture_log(func) =~ ~r/#{@incorrect_url}/
    end
  end
end
