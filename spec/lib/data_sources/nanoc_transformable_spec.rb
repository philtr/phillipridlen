require 'data_sources/nanoc_transformable'

class DummyBinary
  include DataSources::NanocTransformable::Binary

  attr_reader :attributes
  def initialize(attrs) = @attributes = attrs
end

class DummyTextual
  include DataSources::NanocTransformable::Textual

  attr_reader :attributes
  def initialize(attrs) = @attributes = attrs
end

class DummyNoMode
  include DataSources::NanocTransformable

  attr_reader :attributes
  def initialize(attrs) = @attributes = attrs
end

RSpec.describe DataSources::NanocTransformable do
  let(:ds) { double('data_source') }

  it 'builds binary nanoc items' do
    dummy = DummyBinary.new(filename: '/foo.jpg')
    expect(ds).to receive(:new_item).with('/foo.jpg', dummy.attributes, instance_of(Nanoc::Core::Identifier), binary: true)
    dummy.to_nanoc_item(ds)
  end

  it 'builds textual nanoc items' do
    dummy = DummyTextual.new(filename: '/id', content: 'text')
    expect(ds).to receive(:new_item).with('text', dummy.attributes, instance_of(Nanoc::Core::Identifier), binary: false)
    dummy.to_nanoc_item(ds)
  end

  it 'raises when no mode included' do
    dummy = DummyNoMode.new(filename: 'id')
    expect { dummy.filename_or_content }.to raise_error(RuntimeError)
  end
end
