# Proyecto Apache

Para realizar la comprobación del HTML y del PHP necesitaremos 3 archivos: **docker-compose**, **index.html**, **prueba.php**.

El _docker-compose_ es el que levanta el servicio, mientras que los otros 2 archivos son un **_.html_** y un **_.php_** con un texto de prueba para la comprobación, estos 2 los meteremos en una carpeta aparte del _docker-compose_, a esta le llamamos **_html_**.

## Configuración del _docker-compose_

Antes de nada creamos la subnet con:
~~~
docker network create  --subnet 10.26.0.0/16 --gateway 10.26.0.1 bind9_subnetasir_apache
~~~

Aquí crearemos el servicio _asir_apache_, a este le asignaremos:

1. Un nombre
2. La imagen de apache PHP
3. El puerto
4. La IP fija
5. Los volumenes

> Realmente no necesitamos el segundo volumen, que es de la configuración, ya que eso es para algo posterior, para esta comprobación no es necesario.

Nos debería quedar así:
~~~
services: 
  asir_apache:
    container_name: asir_apache
    image: php:7.2-apache
    ports:
      - 8080:80
      - 8000:8000
    networks:
      bind9_subnetasir_apache:
        ipv4_address: 10.26.0.25
    volumes:
      - ./html:/var/www/html
      - ./confApache:/etc/apache2
~~~
Fuera de services crearmos la red

~~~
networks:
  bind9_subnetasir_apache:
    external: true
~~~

>En caso de poner ese volumen de configuración que no necesitamos, tendremos que crear el volumen con lo siguiente:
~~~
volumes:
  confApache:
~~~

Ya con esto creado, ahora seguimos con los archivos de prueba

## Archivos **.html** y **.php**

Estos archivos como son para la comprobación, están praqcticamente vacíos.

El _.html_ pondremos simplemente _Hola mundo_
~~~
<h1>Hola mundo</h1>
~~~
Y el_.php_ pondremos el (_phpinfo()_) que nos muestra ejemplos de php
~~~
<?php
phpinfo();
?>
~~~
Ya con esto solo tendríamos que hacer un **docker-compose up** para levantar el servicio y realizar la comprobación.

## Comprobación

Para comprobar simplemente iremos al navegador y pondremos:
>localhost:8080

Esto nos abrirá el _index.html_ y nos aparecerá el "Hola mundo" que contiene

![Si lees esto es que el link que use no funciona, por lo que para ver el ping entra en la imagen del Git](https://github.com/HugoCea/ProyactoApache/blob/master/imagenes/imgHTML.png)

Mientras que para el ver el _.php_ ecribiremos lo siguiente:
>localhost:8080/prueba.php

De esta forma nos mostrara el contenido de _prueba.php_ que en este caso es la página de información de PHP.

![Si lees esto es que el link que use no funciona, por lo que para ver el ping entra en la imagen del Git](https://github.com/HugoCea/ProyactoApache/blob/master/imagenes/imgPHP.png)


# DNS y VirtualHost
## DNS

Añadimos el DNS al docker-compose, configurando los volumenes de la configuración y colocándole una IP fija

~~~
asir_bind9_apache:
    container_name: asir_bind9_apache
    image: internetsystemsconsortium/bind9:9.16
    ports:
      - 5401:53/udp
      - 5401:53/tcp
    networks:
      bind9_subnetasir_apache:
        ipv4_address: 10.26.0.253
    volumes:
      - /home/asir2a/Documentos/SRI/ProyectoApache/confDNS/conf:/etc/bind
      - /home/asir2a/Documentos/SRI/ProyectoApache/confDNS/zonas:/var/lib/bind
~~~

Ahora en las rutas donde asignamos los volumnes para crear las carpetas **(/conf y /zonas)**. En la primera creamos el fichero _named.conf_ con lo siguiente:

~~~
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
~~~

El fichero _named.conf.local_ donde pondremos:

~~~
zone "fabulas.com." {
        type master;
        file "/var/lib/bind/db.fabulas.com";
        notify explicit;
        allow-query {
                any;
        };
};

~~~

Y por último el _named.conf.options_ con los siguiente ajustes:

~~~
options {
        directory "/var/cache/bind";
        listen-on { any; };
        listen-on-v6 { any; };
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
        forward only;
        allow-recursion {
                none;
        };
        allow-transfer {
                none;
        };
        allow-update {
                none;
        };
        allow-query {
                any;
        };
};

~~~

En la carpeta zonas creamos el archivo _db.fabulas.com_ y ponemos lo siguiente:
>Apuntamos maravillosas al apache
>Y oscuras apuntando a maravillosas como alias

~~~
$TTL    36000
@       IN      SOA     ns.fabulas.com. hceamarin.danielcastelao.org. (
                   2022000           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@               IN      NS      ns.fabulas.com.
ns              IN      A       10.26.0.253
maravillosas    IN      A       10.26.0.25
oscuras         IN      CNAME   maravillosas
~~~

Volviendo al docker-compose creamos el cliente alpine:

~~~
  asir_cliente_apache:
    container_name: asir_cliente_apache
    image: alpine
    networks:
      - bind9_subnetasir_apache
    stdin_open: true
    tty: true
    dns:
      - 10.26.0.253
~~~


## VirtualHost

Debemos de ir a la configuración del apache, concretamente _sites-available_ y crearemos un copia del _000-default.conf_ a la que llamaremos _001-default-conf_

La primera opción de todas nos deja asignarle un puerto, el _000_ será: 
> <VirtualHost *:80>

También cmabiamos el nombre del server, este tendra:
>ServerName maravillosas.fabulas.com

Y por último le tendremos que poner la ruta al archivo que queremos que abra:
>DocumentRoot /var/www/html/Sitio2

Mientras que el _001_ será:
><VirtualHost *:8000>
>ServerName oscuras.fabulas.com
>DocumentRoot /var/www/html/Sitio2

Ahora solo nos faltaría que estos archivo de _sites-available_ se pasen a _sites-enable_

Para ello tendremos que entrar en el apache y escribir lo siguiente:

>a2ensite 000-default
>a2ensite 001-default

Ahora con hacer un stop y un start debería de funcionar

# Comprobacion

Hacemos un wget a **maravillosas.fabulas.com** y este nos devuelve el _index.html_

![wget marvillosas](https://github.com/HugoCea/ProyactoApache/blob/master/imagenes/imgMaravillosas.png)

Y cuando lo hacemos a **oscuras.fabulas.com:8000/prueba.php** debemos especificar el puerto y el archivo en este caso ya que no es el default.
Y este nos devuelde la info de PHP

![wget oscuras](https://github.com/HugoCea/ProyactoApache/blob/master/imagenes/imgOscuras.png)















