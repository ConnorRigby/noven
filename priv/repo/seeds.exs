# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Noven.Repo.insert!(%Noven.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

default_email = "test@test.com"
default_password = "password123456"
alias Noven.Repo

{:ok, user} =
  Noven.Accounts.register_user(%{
    email: default_email,
    password: default_password
  })

{:ok, device} =
  %Noven.Devices.Device{
    serial: "abcdef",
    name: "test",
    user_id: user.id
  }
  |> Repo.insert()

token = Noven.Devices.generate_token(device)

IO.warn(
  """
  User Credentials: #{user.email}:#{default_password}
  Device Token: #{token}
  """,
  []
)
