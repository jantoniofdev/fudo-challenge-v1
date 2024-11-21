require 'rack'
require 'jwt'
require 'openssl'
require './user'
require './product_store'
require './product'
require './index_page'
require './authentication'

class App
  def call(env)
    request = Rack::Request.new(env)
   
    case request.path_info
    when '/'
      [200, { 'content-type' => 'text/html' }, [IndexPage.content]]
    when '/products'
      return [401, {'content-type' => 'application/json'}, [{ errors: "Token de autorización inválido" }.to_json]] unless env.has_key?('HTTP_AUTHORIZATION') && Authentication.authenticate!(env['HTTP_AUTHORIZATION'])      
      case request.request_method
        when 'POST'
          data = JSON.parse(request.body.read)
          if data['products'].nil? || data['products'].empty? || data['products'].length == 0 || data['products'].any? { |product| product['name'].nil? || product['name'].empty? }
            return [400, {'content-type' => 'application/json'}, [{ "error": "Faltan campos requeridos o formato incorrecto" }.to_json]]
          end
          Product.create(data)
          [200, {'content-type' => 'application/json'}, [{"message": "Agregando Productos..."}.to_json]]
        when 'GET'
          if request.params['id'].nil? || request.params['id'].empty?
            [200, {'content-type' => 'application/json'}, [ProductStore.all_products.to_json]]
          else
            [200, {'content-type' => 'application/json'}, [ProductStore.find_product_by_id(request.params['id']).to_json]]
          end 
      end
    when '/product_status'
      if request.get?
        status = ProductStore.get_product_status(request.params['id'])
        if status
          [200, {'content-type' => 'application/json'}, [{ "id": request.params['id'], "status": status }.to_json]]
        else
          [404, {'content-type' => 'application/json'}, [{ error: "Producto no encontrado" }.to_json]]
        end
      end
    when '/register'
      data = JSON.parse(request.body.read)
      
      return [400, 
        {'content-type' => 'application/json'}, 
        [{"error": "Faltan campos requeridos"}.to_json]
      ] if (data['username'].empty? || data['password'].empty?)

      user = User.new(data['username'], data['password'])
      User.add_user(user)

      if User.find_user_by_username(data['username'])
        [400, {'content-type' => 'application/json'}, [{ "message": "Usuario ya existente!" }.to_json]]
      end

      [200, {'content-type' => 'application/json'}, [{ "message": "Usuario registrado exitosamente" }.to_json]]
    when '/users'
      return [401, {'content-type' => 'application/json'}, [{ errors: "Token de autorización inválido" }.to_json]] unless env.has_key?('HTTP_AUTHORIZATION') && Authentication.authenticate!(env['HTTP_AUTHORIZATION'])
      
      case request.request_method
        when 'GET'
          [200, {'content-type' => 'application/json'}, [User.all_users.to_json]]
      end
    when '/login' 
      data = JSON.parse(request.body.read)
      
      if data['username'].empty? || data['password'].empty?
        return [400,
          {'content-type' => 'application/json'},
          [{"errors": "Faltan campos requeridos o formato incorrecto"}.to_json]
        ]
      end
      
      if Authentication.user_valid?(data['username'])
        if Authentication.password_valid?(data['username'], data['password'])
          [200,
            {'content-type' => 'application/json', 'authorization' => Authentication.generate_token(data['username'])}, 
            [{"message": "Logged In Success!"}.to_json]
          ]
        else
          [401,
            {'content-type' => 'application/json'},
            [{"errors": "Invalid credentials"}.to_json]
          ]
        end      
      else
        [401,
          {'content-type' => 'application/json'}, 
          [{"errors": "User Not Found"}.to_json]
        ]
      end
    else
      [404,
        {'content-type' => 'application/json'}, 
        [{"errors": "Not Found"}.to_json]
      ]
    end
  end
end
