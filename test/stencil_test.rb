require 'rubygems'
require 'active_support'
require 'test/spec'
require 'flexmock/test_unit'

Dependencies.load_paths << File.dirname(__FILE__) + '/../lib'

class Foo
  include Stenciling
end

class SimpleStencil < Stencil
    
  attr_reader :args, :block
  def initialize(*args, &block)
    @args = args
    @block = block
  end
  
  def draw
    "Some simple output"
  end
  
  def child
    children << delegate_to_template(Child.new)
  end
  
  def children
    @children ||= []
  end
  
  class Child
  end
  
end

class SimplesStencil < Stencil
  # For pluralization test
end

context "Stencil" do
  
  specify "templates with stenciling can instantiate stencil subclasses via method missing" do
    assert_kind_of Stenciling, Foo.new
    foo = Foo.new
    stencil = nil
    assert_nothing_raised { stencil = foo.simple }
    assert_raises(NoMethodError) { bad_stencil = foo.simple_stencil }
    assert_kind_of SimpleStencil, stencil
    assert_equal foo, stencil.template
  end
  
  specify "pluralization matters in template method missing instantiation" do
    assert_kind_of Stenciling, Foo.new
    foo = Foo.new
    stencil = nil
    assert_nothing_raised { stencil = foo.simples }
    assert_raises(NoMethodError) { bad_stencil = foo.simples_stencil }
    assert_kind_of SimplesStencil, stencil
    assert_equal foo, stencil.template
  end
  
  specify "receive arguments passed during instantiation from template" do
    args = %w(args to pass)
    block = lambda { :this_is_just_a_sample_block_to_pass_to_the_stencil }
    stencil = stencil_with_mock_template(*args, &block)
    assert_equal args, stencil.args
    assert_equal block, stencil.block
  end
  
  specify "forward missing methods to template" do
    assert_equal :called_template, stencil_with_mock_template.some_method_template_responds_to
  end
  
  specify "to_s method uses draw method to generate content" do
    stencil = stencil_with_mock_template
    assert_equal stencil.draw.to_s, stencil.to_s
  end
  
  specify "can create children that delegate to template" do
    stencil = stencil_with_mock_template
    assert stencil.respond_to?(:children)
    assert stencil.children.empty?
    assert_nothing_raised do
      stencil.child
    end
    assert_equal 1, stencil.children.size
    assert_equal :called_template, stencil.children.first.some_method_template_responds_to
  end
  
  #######
  private
  #######

  def stencil_with_mock_template(*args, &block)
    returning SimpleStencil.new(*args, &block) do |stencil|
      stencil.template = flexmock('template') do |template|
        template.should_receive(:some_method_template_responds_to).and_return(:called_template)
      end
    end
  end
  
end
