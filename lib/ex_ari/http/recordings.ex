defmodule ARI.HTTP.Recordings do
  @moduledoc """
  HTTP Interface for CRUD operations on Recording objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Recordings+REST+API

  Live Recording Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-LiveRecording
  Stored Recording Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-StoredRecording
  """

  use ARI.HTTPClient, "/recordings"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of recordings that are complete
  """
  @spec list_stored :: Response.t()
  def list_stored do
    GenServer.call(__MODULE__, :list_stored)
  end

  @doc """
  Get a stored recording's details

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec get_stored(String.t()) :: Response.t()
  def get_stored(name) do
    GenServer.call(__MODULE__, {:get_stored, name})
  end

  @doc """
  Get the file associated with the stored recording.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec get_stored_file(String.t()) :: Response.t()
  def get_stored_file(name) do
    GenServer.call(__MODULE__, {:get_stored_file, name})
  end

  @doc """
  Copy a stored recording.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
    payload: map of the parameters and values to pass to Asterisk
      destinationRecordingName: (required) the destination name of the recording
  """
  @spec copy_stored(String.t(), map()) :: Response.t()
  def copy_stored(name, %{destinationRecordingName: _} = payload) do
    GenServer.call(__MODULE__, {:copy_stored, name, payload})
  end

  @doc """
  Deletes a stored recording

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec delete_stored(String.t()) :: Response.t()
  def delete_stored(name) do
    GenServer.call(__MODULE__, {:delete_stored, name})
  end

  @doc """
  Retrieve list of live recordings

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec get_live(String.t()) :: Response.t()
  def get_live(name) do
    GenServer.call(__MODULE__, {:get_live, name})
  end

  @doc """
  Stop a live recording and discard it

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec cancel_live(String.t()) :: Response.t()
  def cancel_live(name) do
    GenServer.call(__MODULE__, {:cancel_live, name})
  end

  @doc """
  Stop a live recording and store it

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec stop_live(String.t()) :: Response.t()
  def stop_live(name) do
    GenServer.call(__MODULE__, {:stop_live, name})
  end

  @doc """
  Pause a live recording.
  Pausing a recording suspends silence detection, which will be restarted when the recording is unpaused.
  Paused time is not included in the accounting for maxDurationSeconds.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec pause_live(String.t()) :: Response.t()
  def pause_live(name) do
    GenServer.call(__MODULE__, {:pause_live, name})
  end

  @doc """
  Unpause a live recording.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec unpause_live(String.t()) :: Response.t()
  def unpause_live(name) do
    GenServer.call(__MODULE__, {:unpause_live, name})
  end

  @doc """
  Mute a live recording.
  Muting a recording suspends silence detection, which will be restarted when the recording is unmuted.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec mute_live(String.t()) :: Response.t()
  def mute_live(name) do
    GenServer.call(__MODULE__, {:mute_live, name})
  end

  @doc """
  Unmute a live recording.

  ## Parameters
    name: String (UTF-8) that represents the recording's name
  """
  @spec unmute_live(String.t()) :: Response.t()
  def unmute_live(name) do
    GenServer.call(__MODULE__, {:unmute_live, name})
  end

  @impl true
  def handle_call(:list_stored, from, state) do
    {:noreply, request("GET", "/stored", from, state)}
  end

  @impl true
  def handle_call({:get_stored, name}, from, state) do
    {:noreply, request("GET", "/stored/#{name}", from, state)}
  end

  @impl true
  def handle_call({:get_stored_file, name}, from, state) do
    {:noreply, request("GET", "/stored/#{name}/file", from, state)}
  end

  @impl true
  def handle_call({:copy_stored, name, payload}, from, state) do
    {:noreply,
     request("POST", "/stored/#{name}/copy?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:delete_stored, name}, from, state) do
    {:noreply, request("DELETE", "/stored/#{name}", from, state)}
  end

  @impl true
  def handle_call({:get_live, name}, from, state) do
    {:noreply, request("GET", "/live/#{name}", from, state)}
  end

  @impl true
  def handle_call({:cancel_live, name}, from, state) do
    {:noreply, request("DELETE", "/live/#{name}", from, state)}
  end

  @impl true
  def handle_call({:stop_live, name}, from, state) do
    {:noreply, request("POST", "/live/#{name}/stop", from, state)}
  end

  @impl true
  def handle_call({:pause_live, name}, from, state) do
    {:noreply, request("POST", "/live/#{name}/pause", from, state)}
  end

  @impl true
  def handle_call({:unpause_live, name}, from, state) do
    {:noreply, request("DELETE", "/live/#{name}/pause", from, state)}
  end

  @impl true
  def handle_call({:mute_live, name}, from, state) do
    {:noreply, request("POST", "/live/#{name}/mute", from, state)}
  end

  @impl true
  def handle_call({:unmute_live, name}, from, state) do
    {:noreply, request("DELETE", "/live/#{name}/mute", from, state)}
  end
end
