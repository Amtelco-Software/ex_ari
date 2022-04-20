defmodule ARI.HTTP.Bridges do
  @moduledoc """
  HTTP Interface for CRUD operations on Bridge Objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Bridges+REST+API

  Bridge Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Bridge
  """
  use ARI.HTTPClient, "/bridges"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of active channels in Asterisk
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Get bridge details

  ## Parameters
    id: String (UTF-8) that represents the Bridge ID to retrieve details for
  """
  @spec get(String.t()) :: Response.t()
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @doc """
  Create a new bridge. This bridge persists until it has been shut down, or Asterisk has been shut down
  This allows for a bridge to be created without specifying a bridgeId (Asterisk will assign it if not specified)

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      type: Comma separated list of bridge type attributes (mixing, holding, dtmf_events, proxy_media, video_sfu, video_single).
      bridgeId: Unique ID to give to the bridge being created. (Asterisk will assign one if not specified)
      name: Name to give to the bridge being created.
  """
  @spec create(map()) :: Response.t()
  def create(payload) do
    GenServer.call(__MODULE__, {:create, payload})
  end

  @doc """
  Create a new bridge or update an existing one. This bridge persists until it has been shut down, or Asterisk has been shut down

  ## Parameters
    id: String (UTF-8) that represents the Bridge ID to retrieve details for
    payload: map of the parameters and values to pass to Asterisk
      type: Comma separated list of bridge type attributes (mixing, holding, dtmf_events, proxy_media, video_sfu, video_single).
      name: Set the name of the bridge.
  """
  @spec update(String.t(), map()) :: Response.t()
  def update(id, payload) do
    GenServer.call(__MODULE__, {:update, id, payload})
  end

  @doc """
  Shut down a bridge. If any channels are in this bridge, they will be removed and resume whatever they were doing beforehand.

  ## Parameters
    id: String (UTF-8) that represents the Bridge ID to shut down
  """
  @spec delete(String.t()) :: Response.t()
  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
  end

  @doc """
  Add channel(s) to a bridge

  ## Parameters
    id: String (UTF-8) that represents the Bridge ID to add channel(s) to
    payload: map of the parameters and values to pass to Asterisk
      channel: (required) Ids of channels to add to bridge
        Allows comma seperated values
      role: Channel's role in the bridge
      absorbDTMF: Absorb DTMF coming from this channel, preventing it to pass through to the bridge
        Allowed values: 'false', 'true'
      mute: Mute audio from this channel, preventing it to pass through to the bridge
        Allowed values: 'false', 'true'
      inhibitConnectedLineUpdates: Do not present the identity of the newly connected channel to other bridge members
        Allowed values: 'false', 'true'
  """
  @spec add_channels(String.t(), map()) :: Response.t()
  def add_channels(id, %{channel: _} = payload) do
    GenServer.call(__MODULE__, {:add_channels, id, payload})
  end

  @doc """
  Remove channel(s) from a bridge

  ## Parameters
    id: String (UTF-8) that represents the Bridge ID to remove channel(s) from
    payload: map of the parameters and values to pass to Asterisk
      channel: (required) Ids of channels to remove from bridge
        Allows comma seperated values
  """
  @spec remove_channels(String.t(), map()) :: Response.t()
  def remove_channels(id, %{channel: _} = payload) do
    GenServer.call(__MODULE__, {:remove_channels, id, payload})
  end

  @doc """
  Set a channel as the video source in a multi-party mixing bridge. This operation has no effect on bridges with two or fewer participants.

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
    channel: String (UTF-8) that represents the Channel's Id
  """
  @spec set_video_source(String.t(), String.t()) :: Response.t()
  def set_video_source(id, channel_id) do
    GenServer.call(__MODULE__, {:set_video_source, id, channel_id})
  end

  @doc """
  Removes any explicit video source in a multi-party mixing bridge. This operation has no effect on bridges with two or fewer participants.
  When no explicit video source is set, talk detection will be used to determine the active video

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
  """
  @spec clear_video_source(String.t()) :: Response.t()
  def clear_video_source(id) do
    GenServer.call(__MODULE__, {:clear_video_source, id})
  end

  @doc """
  Play music on hold to a bridge or change the MOH class that is playing.

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
    payload: map of the parameters and values to pass to Asterisk
      moh_class: Music On Hold Class
  """
  @spec start_moh(String.t(), map()) :: Response.t()
  def start_moh(id, payload) do
    GenServer.call(__MODULE__, {:start_moh, id, payload})
  end

  @doc """
  Stop playing music on hold to a bridge. This will only stop music on hold being played via a start_moh

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
  """
  @spec stop_moh(String.t()) :: Response.t()
  def stop_moh(id) do
    GenServer.call(__MODULE__, {:stop_moh, id})
  end

  @doc """
  Start playback of media on a bridge. The media URI may be any of a number of URI's.
  Currently sound:, recording:, number:, digits:, characters:, and tone: URI's are supported.
  This operation creates a playback resource that can be used to control the playback of media (pause, rewind, fast forward, etc.)

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
    payload: map of the parameters and values to pass to Asterisk
      media: (required) Media URIs to play.
        Allows comma seperated values.
      lang: For sounds, select language for sound.
      offsetms: Number of ms to skip before playing. Only applies to the first URI if multiple media URIs are specified.
        Allowed range: Min: 0, Max: None
      skipms: Number of ms to skip for forward/reverse operations.
        Default: 3000
        Allowed range: Min: 0, Max: None
      playbackId: Playback Id
  """
  @spec play(String.t(), map()) :: Response.t()
  def play(id, %{media: _} = payload) do
    GenServer.call(__MODULE__, {:play, id, payload})
  end

  @doc """
  Start record of media on a bridge.  This records the mixed audio from all channels participating in this bridge

  ## Parameters
    id: String (UTF-8) that represents the Bridge's Id
    payload: map of the parameters and values to pass to Asterisk
      name: (required) Recording's filename
      format: (required) Format to encode audio in
      maxDurationSeconds: Maximum duration of the recording, in seconds. 0 for no limit.
        Allowed range: Min: 0, Max: None
      maxSilenceSeconds: Maximum duration of silence, in seconds. 0 for no limit.
        Allowed range: Min: 0, Max: None
      ifExists: Action to take if a recording with the same name already exists
        Default: fail
        Allowed values: fail, overwrite, append
      beep: Play beep when recording begins
        Allowed values: 'false', 'true'
      terminateOn: DTMF input to terminate recording
        Default: none
        Allowed values: none, any, *, #
  """
  @spec record(String.t(), map()) :: Response.t()
  def record(id, %{name: _, format: _} = payload) do
    GenServer.call(__MODULE__, {:record, id, payload})
  end

  @impl true
  def handle_call(:list, from, state) do
    {:noreply, request("GET", "", from, state)}
  end

  @impl true
  def handle_call({:get, id}, from, state) do
    {:noreply, request("GET", "/#{id}", from, state)}
  end

  @impl true
  def handle_call({:delete, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}", from, state)}
  end

  @impl true
  def handle_call({:create, payload}, from, state) do
    {:noreply, request("POST", "?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:update, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:add_channels, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/addChannel?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:remove_channels, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/removeChannel?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:set_video_source, id, channel_id}, from, state) do
    {:noreply, request("POST", "/#{id}/videoSource/#{channel_id}", from, state)}
  end

  @impl true
  def handle_call({:clear_video_source, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/videoSource", from, state)}
  end

  @impl true
  def handle_call({:start_moh, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/moh?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:stop_moh, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/moh", from, state)}
  end

  @impl true
  def handle_call({:play, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/play/?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:record, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/record?#{encode_params(payload)}", from, state)}
  end
end
