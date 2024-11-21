require 'sidekiq'
require 'redis'
require './product_store'
require './product'

class ProductWorker
  include Sidekiq::Worker
  REDIS = Redis.new(host: "localhost", port: 6379)

  def perform(data)
    product = Product.new(data["name"])
    ProductStore.set_product_status(product.id, "pending")

    sleep 5

    ProductStore.add_product(product)
    ProductStore.set_product_status(product.id, "completed")
  end
end