defmodule ReWeb.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(ReWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ReWeb.Gettext, "errors", msg, opts)
    end
  end
end
