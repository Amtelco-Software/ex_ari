defmodule ARI.HTTP.Channels do
  @moduledoc """
  HTTP Interface for CRUD operations on Channel objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Channels+REST+API

  Channel Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk16RESTDataModels-Channel
  """
  use ARI.HTTPClient, "/channels"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of active channels in Asterisk
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Get a channel's details

  ## Parameters
    id: String (UTF-8) that represents the Channel ID to retrieve details for
  """
  @spec get(String.t()) :: Response.t()
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @doc """
  Create a new channel (originate).
  The new channel is created immediately and a snapshot of it returned.
  If a Stasis application is provided it will be automatically subscribed to the originated channel for further events and updates.

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      endpoint: (required) Endpoint to call
      extension: The extension to dial after the endpoint answers. Mutually exclusive with 'app'.
      context: The context to dial after the endpoint answers. If omitted, uses 'default'. Mutually exclusive with 'app'.
      priority: The priority to dial after the endpoint answers. If omitted, uses 1. Mutually exclusive with 'app'.
      label:  label to dial after the endpoint answers. Will supersede 'priority' if provided. Mutually exclusive with 'app'.
      app: The application that is subscribed to the originated channel. When the channel is answered, it will be passed to this Stasis application. Mutually exclusive with 'context', 'extension', 'priority', and 'label'.
      appArgs: The application arguments to pass to the Stasis application provided by 'app'. Mutually exclusive with 'context', 'extension', 'priority', and 'label'.
      callerId: CallerID to use when dialing the endpoint or extension.
      timeout: Timeout (in seconds) before giving up dialing, or -1 for no timeout. Default: 30
      otherChannelId: The unique id to assign the second channel when using local channels.
      originator: The unique id of the channel which is originating this one.
      formats: The format name capability list to use if originator is not specified. Ex. "ulaw,slin16". Format names can be found with "core show codecs".
    variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation.
      Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
  """
  @spec originate(map(), %{variables: %{}}) :: Response.t()
  def originate(%{endpoint: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:originate, payload, variables})
  end

  @doc """
  Create a new channel (originate with id).
  The new channel is created immediately and a snapshot of it returned.
  If a Stasis application is provided it will be automatically subscribed to the originated channel for further events and updates.

  ## Parameters
    id: String (UTF-8) - unique id to assign the channel on creation
    payload: map of the parameters and values to pass to Asterisk
      endpoint: (required) Endpoint to call
      extension: The extension to dial after the endpoint answers. Mutually exclusive with 'app'.
      context: The context to dial after the endpoint answers. If omitted, uses 'default'. Mutually exclusive with 'app'.
      priority: The priority to dial after the endpoint answers. If omitted, uses 1. Mutually exclusive with 'app'.
      label:  label to dial after the endpoint answers. Will supersede 'priority' if provided. Mutually exclusive with 'app'.
      app: The application that is subscribed to the originated channel. When the channel is answered, it will be passed to this Stasis application. Mutually exclusive with 'context', 'extension', 'priority', and 'label'.
      appArgs: The application arguments to pass to the Stasis application provided by 'app'. Mutually exclusive with 'context', 'extension', 'priority', and 'label'.
      callerId: CallerID to use when dialing the endpoint or extension.
      timeout: Timeout (in seconds) before giving up dialing, or -1 for no timeout. Default: 30
      otherChannelId: The unique id to assign the second channel when using local channels.
      originator: The unique id of the channel which is originating this one.
      formats: The format name capability list to use if originator is not specified. Ex. "ulaw,slin16". Format names can be found with "core show codecs".
    variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation.
      Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
  """
  @spec originate_with_id(String.t(), map(), %{variables: %{}}) :: Response.t()
  def originate_with_id(id, %{endpoint: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:originate, id, payload, variables})
  end

  @doc """
  Create channel

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      endpoint: (required) Endpoint to call
      app: (required) Stasis Application to place channel into
      appArgs: The application arguments to pass to the Stasis application provided by 'app'. Mutually exclusive with 'context', 'extension', 'priority', and 'label'.
      channelId: The unique id to assign the channel on creation
      otherChannelId: The unique id to assign the second channel when using local channels.
      originator: Unique ID of the calling channel
      formats: The format name capability list to use if originator is not specified. Ex. "ulaw,slin16". Format names can be found with "core show codecs".
    variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation.
      Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
  """
  @spec create(map(), %{variables: %{}}) :: Response.t()
  def create(%{endpoint: _, app: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:create, payload, variables})
  end

  @doc """
  Hangup (i.e. delete) a channel

  ## Parameters
    id: String (UTF-8) - channel id to hangup
    payload: map of the parameters and values to pass to Asterisk
      reason_code: The reason code for hanging up the channel for detail use. Mutually exclusive with 'reason'.
        See detail hangup codes at here. https://wiki.asterisk.org/wiki/display/AST/Hangup+Cause+Mappings
      reason: Reason for hanging up the channel for simple use. Mutually exclusive with 'reason_code'.
        Allowed values: normal, busy, congestion, no_answer, timeout, rejected, unallocated, normal_unspecified, number_incomplete, codec_mismatch, interworking, failure, answered_elsewhere
  """
  @spec hangup(String.t(), map()) :: Response.t()
  def hangup(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:hangup, id, payload})
  end

  @doc """
  Exit Stasis application control, continue execution in Asterisk dialplan

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      context: The dialplan context to continue to
      extension: The dialplan extension to continue to
      priority: The dialplan priority to continue to
      label: The dialplan label to continue to - will supercede 'priority' if both are provided
  """
  @spec continue_in_dialplan(String.t(), map()) :: Response.t()
  def continue_in_dialplan(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:continue_in_dialplan, id, payload})
  end

  @doc """
  Redirect the channel to a different location

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      endpoint: (required) The endpoint to redirect the channel to
  """
  @spec redirect(String.t(), map()) :: Response.t()
  def redirect(id, %{endpoint: _} = payload) do
    GenServer.call(__MODULE__, {:redirect, id, payload})
  end

  @doc """
  Move the channel from this Stasis application to another

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      app: (required) The channel will be passed to this Stasis application
      appArgs: The application arguments to pass to the Stasis application provided by 'app'
  """
  @spec move(String.t(), map()) :: Response.t()
  def move(id, %{app: _} = payload) do
    GenServer.call(__MODULE__, {:move, id, payload})
  end

  @doc """
  Answer a channel

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec answer(String.t()) :: Response.t()
  def answer(id) do
    GenServer.call(__MODULE__, {:answer, id})
  end

  @doc """
  Indicate ringing to a channel

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec ring(String.t()) :: Response.t()
  def ring(id) do
    GenServer.call(__MODULE__, {:ring, id})
  end

  @doc """
  Stop ringing indication on a channel if locally generated

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec ring_stop(String.t()) :: Response.t()
  def ring_stop(id) do
    GenServer.call(__MODULE__, {:ring_stop, id})
  end

  @doc """
  Send provided DTMF to channel

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      dtmf: (required) DTMFs to send
      before: amount of time (ms) to wait before DTMF digits start
      between: amount of time (ms) in between DTMF digits. Default 100
      duration: amount of time (ms) of each DTMF digit playing. Default 100
      after: amount of time (ms) to wait after all DTMF digits end
  """
  @spec send_dtmf(String.t(), map()) :: Response.t()
  def send_dtmf(id, %{dtmf: _} = payload) do
    GenServer.call(__MODULE__, {:send_dtmf, id, payload})
  end

  @doc """
  Mute a channel

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      direction: direction in which to mute audio
        Default: both
        Allowed values: both, in, out
  """
  @spec mute(String.t(), map()) :: Response.t()
  def mute(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:mute, id, payload})
  end

  @doc """
  Unmute a channel

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      direction: direction in which to unmute audio
        Default: both
        Allowed values: both, in, out
  """
  @spec unmute(String.t(), map()) :: Response.t()
  def unmute(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:unmute, id, payload})
  end

  @doc """
  Hold a channel

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec hold(String.t()) :: Response.t()
  def hold(id) do
    GenServer.call(__MODULE__, {:hold, id})
  end

  @doc """
  Remove a channel from hold

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec unhold(String.t()) :: Response.t()
  def unhold(id) do
    GenServer.call(__MODULE__, {:unhold, id})
  end

  @doc """
  Play music on hold to a channel.
  Using media operations such as play on a channel playing MOH in this manner will suspend MOH without resuming automatically.
  If continuing music on hold is desired, the stasis application must reinitiate music on hold.

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      mohClass: Music on hold class to use
  """
  @spec start_moh(String.t(), map()) :: Response.t()
  def start_moh(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:start_moh, id, payload})
  end

  @doc """
  Stop play music on hold to a channel.

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec stop_moh(String.t()) :: Response.t()
  def stop_moh(id) do
    GenServer.call(__MODULE__, {:stop_moh, id})
  end

  @doc """
  Play silence to a channel.
  Using media operations such as play on a channel playing silence in this manner will suspend silence without resuming automatically.

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec start_silence(String.t()) :: Response.t()
  def start_silence(id) do
    GenServer.call(__MODULE__, {:start_silence, id})
  end

  @doc """
  Stop Play silence to a channel.

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec stop_silence(String.t()) :: Response.t()
  def stop_silence(id) do
    GenServer.call(__MODULE__, {:stop_silence, id})
  end

  @doc """
  Start playback of media.
  The media URI may be any number of URI's.
  Currently sound:, recording:, number:, digits:, characters:, and tone: URI's are supported.
  This operation creates a playback resource that can be used to control the playback of media (pause, rewind, fast forward, etc.)

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      media: (required) Media URIs to play.
        Allows comma seperated values
      lang: For sounds, selects language for sound.
      offsetms: Number of ms to skip before playing. Only applies to the first URI if multiple media URIs are specified.
      skipms: Number of ms to skip for forward/reverse operations
        Default 3000
      playbackId: Playback ID.
  """
  @spec play(String.t(), map()) :: Response.t()
  def play(id, %{media: _} = payload) do
    GenServer.call(__MODULE__, {:play, id, payload})
  end

  @doc """
  Start a recording.
  Record audio from a channel.
  Note that this will not capture audio sent to the channel.
  The bridge itself has a record feature if that's what you want.

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      name: (required) Recording's filename
      format: (required) Format to encode audio in
      maxDurationSeconds: Maximum duration of the recording, in seconds. 0 for no limit
        Allowed range: Min: 0, Max: None
      maxSilenceSeconds: Maximum duration of silence, in seconds. 0 for no limi
        Allowed range: Min: 0, Max: None
      ifExists: Action to take if a recording with the same name already exists
        Default: fail
        Allowed values: fail, overwrite, append
      beep: Play beep when recording begins
        Allowed values: 'false', 'true', 'yes', 'no'
      terminateOn: DTMF input to terminate recording
        Default: none
        Allowed valued: none, any, *, #
  """
  @spec record(String.t(), map()) :: Response.t()
  def record(id, %{name: _, format: _} = payload) do
    GenServer.call(__MODULE__, {:record, id, payload})
  end

  @doc """
  Get the value of a channel variable or function

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      variable: (required) The channel variable or function to get
  """
  @spec get_var(String.t(), map()) :: Response.t()
  def get_var(id, %{variable: _} = payload) do
    GenServer.call(__MODULE__, {:get_var, id, payload})
  end

  @doc """
  Set the value of a channel variable or function

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      variable: (required) The channel variable or function to set
      value: The value to set the variable to
  """
  @spec set_var(String.t(), map()) :: Response.t()
  def set_var(id, %{variable: _} = payload) do
    GenServer.call(__MODULE__, {:set_var, id, payload})
  end

  @doc """
  Start snooping. Snoop (spy/whisper) on a specific channel.

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      spy: Direction of audio to spy on
        Default: none
        Allowed values: none, both, out, in
        in = audio coming from the channel
        out = audio going to the channel
      whisper: Direction of audio to whisper into
        Default: none
        Allowed values: none, both, out, in
      app: (required) Stasis Application the snooping channel (created) is placed into
      appArgs: The application arguments to pass to the Stasis Application
      snoopId: Unique ID to assign to snooping channel
  """
  @spec snoop(String.t(), map()) :: Response.t()
  def snoop(id, %{app: _} = payload) do
    GenServer.call(__MODULE__, {:snoop, id, payload})
  end

  @doc """
  Dial a created channel

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      caller: Channel ID of caller
      timeout: Dial timeout
        Allowed range: Min: 0, Max: None
  """
  @spec dial(String.t(), map()) :: Response.t()
  def dial(id, payload \\ %{}) do
    GenServer.call(__MODULE__, {:dial, id, payload})
  end

  @doc """
  Retrieve RTP stats on a channel
  Create a channel to an External Media source/sink

  ## Parameters
    id: String (UTF-8) - channel id
  """
  @spec rtp_stats(String.t()) :: Response.t()
  def rtp_stats(id) do
    GenServer.call(__MODULE__, {:rtp_stats, id})
  end

  @doc """
  Start an External Media session.
  Create a channel to an External Media source/sink

  ## Parameters
    id: String (UTF-8) - channel id
    payload: map of the parameters and values to pass to Asterisk
      app: (required) Stasis Application the external media channel (created) is placed into
      external_host: (required) Hostname/ip:port of external host
      encapsulation: Payload of encapsulation protocol
        Default: rtp
        Allowed values: rtp, audiosocket
      transport: Transport protocol
        Default: udp
        Allowed values: udp, tcp
      connection_type: Connection type (client/server)
        Default: client
        Allowed values: client
      format: (required) Format to encode audio in
      direction: External media direction
        Default: both
        Allowed valued: both
      data: An arbitrary data field
    variables: containers - The "variables" key in the body object holds variable key/value pairs to set on the channel on creation.
      Other keys in the body object are interpreted as query parameters. Ex. { "endpoint": "SIP/Alice", "variables": { "CALLERID(name)": "Alice" } }
  """
  @spec external_media(String.t(), map(), %{variables: %{}}) :: Response.t()
  def external_media(id, %{app: _, external_host: _, format: _} = payload, variables \\ %{variables: %{}}) do
    GenServer.call(__MODULE__, {:external_media, id, payload, variables})
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
  def handle_call({:originate, payload, variables}, from, state) do
    {:noreply, request("POST", "?#{encode_params(payload)}", from, state, variables)}
  end

  @impl true
  def handle_call({:originate, id, payload, variables}, from, state) do
    {:noreply, request("POST", "/#{id}?#{encode_params(payload)}", from, state, variables)}
  end

  @impl true
  def handle_call({:create, payload, variables}, from, state) do
    {:noreply, request("POST", "/create?#{encode_params(payload)}", from, state, variables)}
  end

  @impl true
  def handle_call({:hangup, id, payload}, from, state) do
    {:noreply, request("DELETE", "/#{id}?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:continue_in_dialplan, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/continue?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:redirect, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/redirect?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:move, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/move?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:answer, id}, from, state) do
    {:noreply, request("POST", "/#{id}/answer", from, state)}
  end

  @impl true
  def handle_call({:ring, id}, from, state) do
    {:noreply, request("POST", "/#{id}/ring", from, state)}
  end

  @impl true
  def handle_call({:ring_stop, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/ring", from, state)}
  end

  @impl true
  def handle_call({:send_dtmf, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/dtmf?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:mute, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/mute?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:unmute, id, payload}, from, state) do
    {:noreply, request("DELETE", "/#{id}/mute?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:hold, id}, from, state) do
    {:noreply, request("POST", "/#{id}/hold", from, state)}
  end

  @impl true
  def handle_call({:unhold, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/hold", from, state)}
  end

  @impl true
  def handle_call({:start_moh, id, payload}, from, state) do
    {:noreply,
     request("POST", "/#{id}/moh?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:stop_moh, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/moh", from, state)}
  end

  @impl true
  def handle_call({:start_silence, id}, from, state) do
    {:noreply, request("POST", "/#{id}/silence", from, state)}
  end

  @impl true
  def handle_call({:stop_silence, id}, from, state) do
    {:noreply, request("DELETE", "/#{id}/silence", from, state)}
  end

  @impl true
  def handle_call({:play, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/play?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:record, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/record?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:get_var, id, payload}, from, state) do
    {:noreply, request("GET", "/#{id}/variable?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:set_var, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/variable?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:snoop, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/snoop?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:dial, id, payload}, from, state) do
    {:noreply, request("POST", "/#{id}/dial?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:rtp_stats, id}, from, state) do
    {:noreply, request("GET", "/#{id}/rtp_statistics", from, state)}
  end

  @impl true
  def handle_call({:external_media, id, payload, variables}, from, state) do
    {:noreply, request("POST", "/#{id}/external_media?#{encode_params(payload)}", from, state, variables)}
  end
end
