require 'minitest/autorun'
require 'json'
require 'mocha/minitest'
require './product'

class TestProduct < Minitest::Test
  def setup
    Product.class_variable_set(:@@next_id, 1)
  end

  def test_initialize
    product = Product.new("Apple")
    assert_equal 1, product.id, "El ID del producto debería ser 1"
    assert_equal "Apple", product.name, "El nombre del producto debería ser 'Apple'"

    another_product = Product.new("Banana")
    assert_equal 2, another_product.id, "El ID del producto debería ser 2"
    assert_equal "Banana", another_product.name, "El nombre del producto debería ser 'Banana'"
  end

  def test_to_json
    product = Product.new("Laptop")
    expected_json = { id: 1, name: "Laptop" }.to_json
    assert_equal expected_json, product.to_json, "El JSON generado debería coincidir con el esperado"
  end

  def test_create
    params = { "products" => ["Table", "Chair", "Lamp"] }
    ProductWorker.expects(:perform_async).with("Table").once
    ProductWorker.expects(:perform_async).with("Chair").once
    ProductWorker.expects(:perform_async).with("Lamp").once

    Product.create(params)
  end
end
