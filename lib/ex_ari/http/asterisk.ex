defmodule ARI.HTTP.Asterisk do
  @moduledoc """
  HTTP Interface for CRUD operations on Asterisk

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Asterisk+REST+API

  AsteriskInfo Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-AsteriskInfo
  AsteriskPing Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-AsteriskPing
  ConfigTuple Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-ConfigTuple
  LogChannel Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-LogChannel
  Module Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Module
  Variable Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Variable
  """

  use ARI.HTTPClient, "/asterisk"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve Asterisk system information

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      only: Filter information returned
        Allowed values: build, system, config, status
        Allows comma seperated values
  """
  @spec info(map()) :: Response.t()
  def info(payload \\ %{}) do
    GenServer.call(__MODULE__, {:info, payload})
  end

  @doc """
  Send ping (keep alive). Response pong message

  ## Parameters
  """
  @spec ping :: Response.t()
  def ping() do
    GenServer.call(__MODULE__, :ping)
  end

  @doc """
  Retrieve a dynamic configuration object

  ## Parameters
    config_class: String (UTF-8) - The configuration class containing dynamic configuration objects.
    obj_type: String (UTF-8) - The type configuration object to retrieve.
    id: String (UTF-8) - The unique identify of the object to retrieve
  """
  @spec get_config(String.t(), String.t(), String.t()) :: Response.t()
  def get_config(config_class, obj_type, id) do
    GenServer.call(__MODULE__, {:get_config, config_class, obj_type, id})
  end

  @doc """
  Create or update a dynamic configuration object.

  ## Parameters
    config_class: String (UTF-8) - The configuration class containing dynamic configuration objects.
    obj_type: String (UTF-8) - The type configuration object to create or update.
    id: String (UTF-8) - The unique identify of the object to create or update.
    body: map of the parameters and values to pass to Asterisk
      fields: containers - The body should have a value that is a list of ConfigTuples, which provide the field to update.
        Ex. [ { "attribute": "directmedia", "value": "false" } ]
  """
  @spec put_config(String.t(), String.t(), String.t(), map()) :: Response.t()
  def put_config(config_class, obj_type, id, body \\ %{}) do
    GenServer.call(__MODULE__, {:put_config, config_class, obj_type, id, body})
  end

  @doc """
  Delete a dynamic configuration object.

  ## Parameters
    config_class: String (UTF-8) - The configuration class containing dynamic configuration objects.
    obj_type: String (UTF-8) - The type configuration object to delete.
    id: String (UTF-8) - The unique identify of the object to delete.
  """
  @spec delete_config(String.t(), String.t(), String.t()) :: Response.t()
  def delete_config(config_class, obj_type, id) do
    GenServer.call(__MODULE__, {:delete_config, config_class, obj_type, id})
  end

  @doc """
  Get Asterisk log channel information

  ## Parameters
  """
  @spec get_logging :: Response.t()
  def get_logging do
    GenServer.call(__MODULE__, :get_logging)
  end

  @doc """
  Adds a log channel

  ## Parameters
    channel: String (UTF-8) - Log channel name
    payload: map of the parameters and values to pass to Asterisk
      configuration: (required) levels of the log channel
  """
  @spec add_logging(String.t(), map()) :: Response.t()
  def add_logging(channel, %{configuration: _} = payload) do
    GenServer.call(__MODULE__, {:add_logging, channel, payload})
  end

  @doc """
  Deletes a log channel

  ## Parameters
    channel: String (UTF-8) - Log channel name
  """
  @spec delete_logging(String.t()) :: Response.t()
  def delete_logging(channel) do
    GenServer.call(__MODULE__, {:delete_logging, channel})
  end

  @doc """
  Rotates a log channel

  ## Parameters
    channel: String (UTF-8) - Log channel name
  """
  @spec rotate_logging(String.t()) :: Response.t()
  def rotate_logging(channel) do
    GenServer.call(__MODULE__, {:rotate_logging, channel})
  end

  @doc """
  Get list of Asterisk modules.

  ## Parameters
  """
  @spec get_modules :: Response.t()
  def get_modules do
    GenServer.call(__MODULE__, :get_modules)
  end

  @doc """
  Get Asterisk module information.

  ## Parameters
    name: String (UTF-8) - Module name
  """
  @spec get_module(String.t()) :: Response.t()
  def get_module(name) do
    GenServer.call(__MODULE__, {:get_module, name})
  end

  @doc """
  Load an Asterisk module.

  ## Parameters
    name: String (UTF-8) - Module name
  """
  @spec load_module(String.t()) :: Response.t()
  def load_module(name) do
    GenServer.call(__MODULE__, {:load_module, name})
  end

  @doc """
  Reload an Asterisk module.

  ## Parameters
    name: String (UTF-8) - Module name
  """
  @spec reload_module(String.t()) :: Response.t()
  def reload_module(name) do
    GenServer.call(__MODULE__, {:reload_module, name})
  end

  @doc """
  Unload an Asterisk module.

  ## Parameters
    name: String (UTF-8) - Module name
  """
  @spec unload_module(String.t()) :: Response.t()
  def unload_module(name) do
    GenServer.call(__MODULE__, {:unload_module, name})
  end

  @doc """
  Get the value of a global variable

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      variable: (required) The variable to get
  """
  @spec get_variable(map()) :: Response.t()
  def get_variable(%{variable: _} = payload) do
    GenServer.call(__MODULE__, {:get_variable, payload})
  end

  @doc """
  Set the value of a global variable

  ## Parameters
    payload: map of the parameters and values to pass to Asterisk
      variable: (required) The variable to get
      value: The value to set the variable to
  """
  @spec set_variable(map()) :: Response.t()
  def set_variable(%{variable: _, value: _} = payload) do
    GenServer.call(__MODULE__, {:set_variable, payload})
  end

  @impl true
  def handle_call({:get_variable, payload}, from, state) do
    {:noreply, request("GET", "/variable?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:set_variable, payload}, from, state) do
    {:noreply,
     request("POST", "/variable?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:rotate_logging, channel}, from, state) do
    {:noreply, request("PUT", "/logging/#{channel}/rotate", from, state)}
  end

  @impl true
  def handle_call({:delete_logging, channel}, from, state) do
    {:noreply, request("DELETE", "/logging/#{channel}", from, state)}
  end

  @impl true
  def handle_call({:add_logging, channel, payload}, from, state) do
    {:noreply, request("POST", "/logging/#{channel}?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call(:get_logging, from, state) do
    {:noreply, request("GET", "/logging", from, state)}
  end

  @impl true
  def handle_call(:get_modules, from, state) do
    {:noreply, request("GET", "/modules", from, state)}
  end

  @impl true
  def handle_call({:get_module, name}, from, state) do
    {:noreply, request("GET", "/modules/#{name}", from, state)}
  end

  @impl true
  def handle_call({:load_module, name}, from, state) do
    {:noreply, request("POST", "/modules/#{name}", from, state)}
  end

  @impl true
  def handle_call({:reload_module, name}, from, state) do
    {:noreply, request("PUT", "/modules/#{name}", from, state)}
  end

  @impl true
  def handle_call({:unload_module, name}, from, state) do
    {:noreply, request("DELETE", "/modules/#{name}", from, state)}
  end

  @impl true
  def handle_call({:info, payload}, from, state) do
    {:noreply, request("GET", "/info?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call(:ping, from, state) do
    {:noreply, request("GET", "/ping", from, state)}
  end

  @impl true
  def handle_call({:get_config, config_class, obj_type, id}, from, state) do
    {:noreply, request("GET", "/config/dynamic/#{config_class}/#{obj_type}/#{id}", from, state)}
  end

  @impl true
  def handle_call({:put_config, config_class, obj_type, id, body}, from, state) do
    {:noreply,
     request(
       "PUT",
       "/config/dynamic/#{config_class}/#{obj_type}/#{id}",
       from,
       state,
       body
     )}
  end

  @impl true
  def handle_call({:delete_config, config_class, obj_type, id}, from, state) do
    {:noreply,
     request("DELETE", "/config/dynamic/#{config_class}/#{obj_type}/#{id}", from, state)}
  end

end
