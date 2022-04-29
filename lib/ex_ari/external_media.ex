defmodule ARI.ExternalMedia do
  @moduledoc """
  A Stasis application to handle connecting a call to an external media server.

  ## Example

        Channels.originate(UUID.uuid4(), %{
          endpoint: "PJSIP/+15555550101@ivr",
          app: "transfer",
          appArgs: state.channel,
          callerId: "Citybase, Inc",
          originator: state.channel,
          context: "ivr"
        })

  Give it a channel
  This would be initiated in an event handler for your current call. The `state.channel` should be the ID of the incoming call.

  It receives a channel.
  The stasis channel will have several arguments it receives.  In these arguments will be several settings to know how to connect to the External Media.
  external_host (hostname/ip:port)
  encapsulation: payload encapsulation protocol
          rtp, audiosocket
  transport: Transport protocol
          udp, tcp
  connection_type: Connection type (client/server)
          client is all that asterisk supports right now
  format: Format to encode audio in
  direction: External media direction
          Default: both
          Allowed values: both
  data: An arbitrary data field (not sure how this is used)

  It will create a [Bridge](https://wiki.asterisk.org/wiki/display/AST/Bridges)
  It will create an ExternalMedia channel (https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Channels+REST+API#Asterisk18ChannelsRESTAPI-externalMedia)
  Then, it adds the channel it recieved and the ExternalMedia channel to the bridge.
  Then, the channel will be streaming audio with the ExternalMedia ip/host:port.

    {ARI.Stasis, [sup, %{name: "uuid from Genesis", module: ARI.ExternalMedia}, ws_host, un, pw]}

  """
  use GenServer

  require Logger

  alias ARI.HTTP.Bridges
  alias ARI.HTTP.Channels
  alias ARI.Stasis

  @behaviour Stasis

  @derive Jason.Encoder

  @type t :: %__MODULE__{}

  defstruct [
    :channel,
    :caller,
    :external_host,
    :encapsulation,
    :transport,
    :connection_type,
    :format,
    :direction,
    :start_event
  ]

  def start_link([state]) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    ext_media_channel_id = UUID.uuid4()
    Channels.external_media(%{channelId: ext_media_channel_id, app: "5058aaf2-b3cb-4bf2-ba72-0ac4fc510505", external_host: state.external_host, encapsulation: state.encapsulation, transport: state.transport, connection_type: state.connection_type, format: state.format, direction: state.direction})

    bridge_id = UUID.uuid4()
    Bridges.create(%{bridgeId: bridge_id, name: bridge_id, type: "mixing, dtmf_events"})

    Bridges.add_channels(bridge_id, %{channel: "#{state.channel},#{ext_media_channel_id}"})
    {:ok, state}
  end

  def handle_info(event, state) do
    Logger.debug("External Media Event: #{inspect(event)}")
    {:noreply, state}
  end

  @spec state(String.t(), String.t(), list(), map(), map()) :: Stasis.channel_state()
  def state(channel, caller, [external_host, encapsulation, transport, connection_type, format, direction], start_event, _app_state) do
    Logger.debug("Starting External Media with state: #{channel} - #{caller} - host=#{external_host}, encapsulation=#{encapsulation}, transport=#{transport}, connection_type=#{connection_type}, format=#{format}, direction=#{direction}")

    %__MODULE__{
      channel: channel,
      caller: caller,
      external_host: external_host,
      encapsulation: encapsulation,
      transport: transport,
      connection_type: connection_type,
      format: format,
      direction: direction,
      start_event: start_event
    }
  end
end
