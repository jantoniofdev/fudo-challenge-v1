require 'redis' 

class ProductStore
  REDIS = Redis.new(host: "localhost", port: 6379)

  class << self

    def increment_count
      REDIS.incr("product_count")
    end

    def product_count
      REDIS.get("product_count").to_i
    end

    def get_product_status(id)
      REDIS.get("product_status:#{id}")
    end

    def set_product_status(id, status)
      REDIS.set("product_status:#{id}", status)
    end

    def add_product(product)
      result = { id: product.id, name: product.name }
      REDIS.set("product:#{product.id}", result.to_json)
      increment_count
    end

    def all_products
      products = []
      (1..product_count).map do |id|
        product = REDIS.get("product:#{id}")
        return nil unless product
        data = JSON.parse(product)
        
        products << data
      end

      products
    end

    def find_product_by_id(id)
      product = REDIS.get("product:#{id}")
      return nil unless product
      data = JSON.parse(product)
      
      { id: data["id"], name: data["name"] }
    end
  end
end
