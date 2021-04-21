class BinaryTextContent < Nanoc::Filter
  identifier :binary_text

  type :binary => :text

  def run(_filename, params = {})
    params[:content]
  end
end
