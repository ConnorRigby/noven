defmodule NovenWeb.LayoutView do
  use NovenWeb, :view

  def gravitar_url(%{email: email}) do
    hash = :erlang.md5(email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end
end
