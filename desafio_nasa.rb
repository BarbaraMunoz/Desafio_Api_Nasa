

# ESTO ES LO MISMO SIEMPRE  
require "uri"
require "net/http"
require "json" # SE AGREGA PARA VER EL JSON COMO HASH

# Crear el método request que reciba una url y retorne el hash con los resultados
def request(url_requested)
    url = URI(url_requested)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true # Se agrega esta línea
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER # VERIFY_PEER -> EVITA VULNERABILIDAD ** AGREGARLO SIEMPRE **
    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '5f4b1b36-5bcd-4c49-f578-75a752af8fd5'

    response = http.request(request) 
    return JSON.parse(response.body) # RETORNA HASH
end

data = request("https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=10
&api_key=UlwEiQluWzZ9JtA0zsbuR0kDnDx6GdWFOgXI7nL9")

print data # Imprime
puts # Salto de línea
puts

# Crear un método llamado buid_web_page que reciba el hash de respuesta con todos los datos y construya una página web
# Se crea método buid_web_page
def build_web_page(photos)
    html = "<html>\n<head>\n</head>\n<body>\n<ul>\n" # \n Salto de línea
        photos['photos'].each do |foto|
        html = html + "<li><img src='#{foto['img_src']}'></li>\n"
        end
    html += "</ul>\n</body>\n</html>" # Cierre de html
    html  # Devuelve el contenido HTML actualizado
end
web_page = build_web_page(data) 

# Se crea html
File.write("page.html", web_page)

# Crear un método photos_count que reciba el hash de respuesta y devuelva un nuevo hash con el nombre de la cámara y la cantidad de fotos
def photos_count(respuesta) # Recibe el hash de respuesta como argumento (respuesta).
    counts = Hash.new(0) # Nuevo hash counts con un valor predeterminado de 0 utilizando Hash.new(0). Esto cuenta la cantidad de fotos por cada cámara

    respuesta['photos'].each do |photo|
    camera_name = photo['camera']['name'] #Para cada foto, se accede al nombre de la cámara utilizando photo['camera']['name']. Entra a hash "camera" y al valor de la clave "name".
    counts[camera_name] += 1 # Se incrementa en 1 el contador correspondiente en el hash counts
    end
    counts # Está fuera del bucle each y se devuelve al final del método photos_count. Esto garantiza que el resultado final sea el hash completo con el conteo de fotos por cámara
end

counts = photos_count(data)
print "El hash con el detalle de nombre de la cámara y cantidad de fotos es: #{counts}"
puts
puts

