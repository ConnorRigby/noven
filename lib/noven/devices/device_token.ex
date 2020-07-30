defmodule Noven.Devices.DeviceToken do
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  # @reset_password_validity_in_days 1
  # @confirm_validity_in_days 7
  # @change_email_validity_in_days 7
  @token_validity_in_days 60

  schema "device_tokens" do
    field :token, :binary
    belongs_to :device, Noven.Devices.Device
    timestamps(updated_at: false)
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the device found by the token.
  """
  def verify_token_query(token) do
    query =
      from token in token_query(token),
        join: device in assoc(token, :device),
        where: token.inserted_at > ago(@token_validity_in_days, "day"),
        select: device

    {:ok, query}
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the device e-mail while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as devices don't change
  their email.
  """
  def build_hashed_token(device) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %Noven.Devices.DeviceToken{
       token: hashed_token,
       device_id: device.id
     }}
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_query(token) do
    from Noven.Devices.DeviceToken, where: [token: ^token]
  end

  @doc """
  Gets all tokens for the given device for the given contexts.
  """
  def device_and_contexts_query(device) do
    from t in Noven.Devices.DeviceToken, where: t.device_id == ^device.id
  end
end
