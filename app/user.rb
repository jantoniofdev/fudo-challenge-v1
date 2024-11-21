require './security'

class User
  @@users = []
  @@next_id = 1

  attr_accessor :id, :username, :password

  def initialize(username, password)
    @id = @@next_id
    @username = username
    @password = Security.encripted_password(password)
    @@next_id += 1
  end

  def to_json(*_args)
    { id: @id, username: @username }.to_json
  end

  def self.add_user(user)
    @@users << user
  end

  def self.all_users
    @@users.map do |user|
      { id: user.id, name: user.username }
    end    
  end

  def self.find_user_by_username(username)
    @@users.find { |user| user.username == username }
  end

  def self.find_user_by_id(id)
    @@users.find { |user| user.id == id }
  end
end
