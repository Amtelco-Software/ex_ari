defmodule ARI.HTTP.Mailboxes do
  @moduledoc """
  HTTP Interface for CRUD operations on Mailbox objects

  REST Reference: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Mailboxes+REST+API

  Mailbox Object: https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+REST+Data+Models#Asterisk18RESTDataModels-Mailbox
  """

  use ARI.HTTPClient, "/mailboxes"
  alias ARI.HTTPClient.Response

  @doc """
  Retrieve list of all mailboxes
  """
  @spec list :: Response.t()
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Retrieve the current state of a mailbox

  ## Parameters
    name: String (UTF-8) that represents the name of the mailbox
  """
  @spec get(String.t()) :: Response.t()
  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  @doc """
  Change the state of a mailbox. (Note - implicitly creates the mailbox).

  ## Parameters
    name: String (UTF-8) that represents the name of the mailbox
    payload: map of the parameters and values to pass to Asterisk
      oldMessages: (required) Count of old messages in the mailbox
      newMessages: (required) Count of new messages in the mailbox
  """
  @spec update(String.t(), map()) :: Response.t()
  def update(name, %{oldMessages: _, newMessages: _} = payload) do
    GenServer.call(__MODULE__, {:update, name, payload})
  end

  @doc """
  Destroy a mailbox

  ## Parameters
    name: String (UTF-8) that represents the name of the mailbox
  """
  @spec delete(String.t()) :: Response.t()
  def delete(name) do
    GenServer.call(__MODULE__, {:delete, name})
  end

  @impl true
  def handle_call(:list, from, state) do
    {:noreply, request("GET", "", from, state)}
  end

  @impl true
  def handle_call({:get, name}, from, state) do
    {:noreply, request("GET", "/#{name}", from, state)}
  end

  @impl true
  def handle_call({:update, name, payload}, from, state) do
    {:noreply,
     request("PUT", "/#{name}?#{encode_params(payload)}", from, state)}
  end

  @impl true
  def handle_call({:delete, name}, from, state) do
    {:noreply, request("DELETE", "/#{name}", from, state)}
  end
end
