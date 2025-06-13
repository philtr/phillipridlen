# Filter that treats a binary item as textual content.
# The file contents are ignored and supplied text is passed through.
#
class BinaryTextContent < Nanoc::Filter
  identifier :binary_text

  type binary: :text

  def run(_filename, params = {})
    params[:content]
  end
end
