defmodule Cassette.Client.GenerateSt do
  @moduledoc """
  Generates CAS Service Ticket
  """

  use HTTPoison.Base

  alias Cassette.Config
  alias Cassette.Client
  alias HTTPoison.Error
  alias HTTPoison.Response

  @type response ::
          {:error, :bad_tgt}
          | {:ok, String.t()}
          | {:fail, pos_integer(), String.t()}
          | {:fail, :unknown}

  @doc """
  Do request to cas service to get a service ticket from ticket granting
  tickets
  """
  @spec perform(Config.t(), String.t(), String.t()) :: response
  def perform(config = %Config{base_url: base_url}, tgt, service) do
    url = "#{base_url}/v1/tickets/#{tgt}"
    options = Client.options(config)
    params = {:form, [service: service]}
    headers = []

    case post(url, params, headers, options) do
      {:ok, %Response{status_code: 404}} ->
        {:error, :bad_tgt}

      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %Response{status_code: status_code, body: body}} ->
        {:fail, status_code, body}

      {:error, %Error{reason: reason}} ->
        {:fail, reason}

      _ ->
        {:fail, :unknown}
    end
  end
end
