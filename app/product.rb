require 'json'
require 'sidekiq'
require './product_worker'

class Product
  @@next_id = 1

  attr_accessor :id, :name

  def initialize(name)
    @id = @@next_id
    @name = name
    @@next_id += 1
  end

  def to_json(*_args)
    { id: @id, name: @name }.to_json
  end

  def self.create(params)
    params["products"].each do |product|
      ProductWorker.perform_async(product)
    end
  end
end