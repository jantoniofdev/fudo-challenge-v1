# fudo-challenge

Requisitos:
- Instalacion de RUBY >= 3.X.X
- Instalacion de Sidekiq
- Instalacion de Redis
- Instalacion de Bundle

Pasos para ejecutar:
- Suponiendo que se tiene instalado todo lo anterior posicionado sobre el folder fudo-challenge/app ejecutamos bundle install
- Luego de instaladas las Gemas especificadas dentro del Gemfile se ejecuta lo siguiente preferiblemente en ese orden:
- redis-server
- sidekiq -r ./product_worker.rb -C sidekiq_config.yml
- rackup

Para ejecuciones de pruebas:
- posicionado sobre el folder fudo-challenge/app ejecutamos:
- ruby -I. -e 'Dir["tests/**/*.rb"].each { |file| require file }'

Para ejecutar los endpoints ejecutar o importar en postman los siguientes curls:

- Register Post Endpoint

curl --location 'http://localhost:9292/register' \
--header 'Content-Type: application/json' \
--data '{
    "username": "admin",
    "password": "admin"
}'

- Login Post Enpoint

curl --location 'http://localhost:9292/login' \
--header 'Content-Type: application/json' \
--data '{
    "username": "admin",
    "password": "admin"
}'

- Users Get Endpoint

curl --location 'http://localhost:9292/users' \
--header 'Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.d2-QSQCJ1fhBdphs0TmLzmdG2A_E06amSpppeZjsnAE'

- Product Post Endpoint

- curl --location 'http://localhost:9292/products' \
--header 'Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.d2-QSQCJ1fhBdphs0TmLzmdG2A_E06amSpppeZjsnAE' \
--header 'Content-Type: application/json' \
--data '{
    "products": [
        {
            "name": "product 1"
        },
        {
            "name": "product 2"
        }
    ]
}'

- Product Get Endpoint

curl --location 'http://localhost:9292/products' \
--header 'Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.d2-QSQCJ1fhBdphs0TmLzmdG2A_E06amSpppeZjsnAE'

- Product Status Get Endpoint

- curl --location 'http://localhost:9292/product_status?id=1' \
--header 'Authorization: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.d2-QSQCJ1fhBdphs0TmLzmdG2A_E06amSpppeZjsnAE'

- Explicacion del proyecto:
- El Challenge de Fudo ha sido una experiencia enriquecedora al conocer un framework nunca antes visto en mi caso
que es con caracteristicas lite para construir aplicaciones de alto performance.

- Detallo cada requerimiento planteado a continuacion:

1. Explicar en un archivo llamado fudo.md qué es lo que es Fudo, en sólo 2 o 3 párrafos, en no
más de 100 palabras. - Se encuentra en el proyecto

2. Explicar brevemente en un archivo llamado tcp.md qué es TCP, en español, en no más de 50
palabras. - Se encuentra en el proyecto

3. Explicar brevemente en un archivo llamado http.md qué es HTTP, en español, en no más de 50
palabras. - Se encuentra en el proyecto

4. Implementar una aplicación rack en Ruby, sin usar Rails, que exponga una API en
json. - Proyecto Fudo-Challenge
- En el proyecto quise minimizar al maximo posible la cantidad de gemas o librerias para utilizar y hacer funcionalidades mas nativas con el lenguaje Ruby.

La API debe exponer:
● Endpoint de autenticación, que reciba usuario y contraseña.
- El endpoint Login envia por body json los parametros username y password para hacer el proceso de autenticacion haciendo las validaciones correspondientes y retornar en caso exitoso un JWT por header response que sera utilizado para enviar por header Authorization a los demas endpoints del flujo.
- Ademas quise incluir los siguientes features para este modulo:
- El endpoint Register gestiona la creacion de usuarios para que luego con sus credenciales puedan logearse y retornar el JWT explicado en el punto anterior. tambien tiene sus validaciones correspondientes como por ejemplo no permitir la creacion de un usuario ya registrado.
este endpoint tiene ademas, un modulo de encriptacion de los password para que persistan encriptados en lugar de persistirlos en texto plano.
Luego para logear el usuario el modulo aplica desencriptacion del token o hash para validar que el password suministrado coincide con el persistido. La persistencia aplicada para el objeto User es en memoria con variables de clases.
- Tambien esta expuesto un Endpoint GET de /users para verificar los usuarios que fueron creados, sin indicar su password.

● Endpoint para creación de productos. Este endpoint debe ser asíncrono, es decir que la
respuesta a esta llamada no debe indicar que el producto ya fue creado, sino que se
creará de forma asíncrona. El producto creado debe estar disponible luego de 5
segundos.
- En este punto se expuso un endpoint POST de products donde puede enviar 1 o N productos para ser persistidos, la persistencia la resolvi con Sidekiq y Redis para hacer encolamientos en segundo plano o asincronos.
- Posee sus validaciones correspondientes y viaja por dos objetos, el primero el un objeto producto que almacena en memoria los datos basicos ID y Name.
- Luego se creo un objeto ProductStore que es un almacen de productos y que va a gestionar finalmente el guardado de productos, la persistencia en este caso como fue requerido es en segundo plano y se disponibiliza despues de 5 segundos. Esta persistencia tambien se hizo en memoria pero usando REDIS.

● Endpoint para consulta de productos.
- Se expuso un endpoint GET de productos para la visualizacion de todos los productos que se van creando, como se indica anteriormente despues de 5 segundos de creado el producto.
- Ademas se agrego la posibilidad de enviar por params un id para hacer la busqueda por ID del producto. en ambos casos la busqueda la hace directamente a REDIS que es donde se requirio presistir esta data.

● Además de estos endpoints, se puede tener cualquier otro endpoint adicional que
facilite el comportamiento asíncrono de la creación de productos.
- Expuse un endpoint GET de informacion de Status del producto, como se solicito no retornar el mensaje de producto creado y ademas se creara de manera asincrona con un delay de 5 segundos, este endpoint cumple la mision de informar si el producto consultado por ID por parametro se encuentra PENDIENTE o COMPLETADO en su creacion.

● Los endpoints relacionados a la creación y consulta de productos deben validar que se
haya autenticado antes.
- Validacion realizada con JWT como se expuso antes.

● La respuesta de la api debe ser comprimida con gzip (siempre que el cliente lo solicite).
- utilizando un Middleware que provee RACK capturo el Encoding tipo gzip en caso que exista y comprimo el response como es solicitado.

Los siguientes casos de /authors y /openapi los expuse usando html en el root o raiz localhost:9292/ y mediante links acceden a cada archivo.
- En este caso utilice un Middleware custom para la captura de request y modificacion del comportamiento esperado en cada caso.

● La API debe estar especificada en un archivo llamado openapi.yaml que siga la
especificación de OpenAPI. Este archivo debe ser expuesto como un archivo estático
en la raíz y nunca debe ser cacheado por los clientes.
- Para cumplir con este comportamiento capturo por middleware el cache=control del request y lo sobreescribo a 0 para que nunca tenga cache sin importar lo que envien tal como fue especificado.

● Se debe exponer también en la raíz un archivo llamado AUTHORS, que indique tu nombre
y apellido. Este archivo también debe ser estático y la respuesta debe indicar que se
cachee por 24 hs.
- En este caso al momento de enviar el response utilice el header cache-control para setear los segundos correspondientes a 24hrs de cacheo.

● No hace falta tener acceso a una base de datos. La persistencia de los productos puede
ser en memoria.
- Cumplo con este caso, en User utilice persistencia con variables de clase para mantener la data durante la ejecucion.
- En products utilice REDIS para persistir la data de productos.
- Utilice un limpiado de cache o memoria en redis usando flush al inicializar la aplicacion.

● Los atributos de los productos es suficiente que sean sólo id y nombre.
- Cumplo este caso.

● Opcionalmente, poder levantar el proyecto en Docker.
- No logre cumplir con este requisito.

● Agregar en el README la forma de levantar el proyecto.
- El presente documento.

● El proyecto debe estar hosteado en GitHub.
- https://github.com/jantoniofdev/fudo-challenge-v1
