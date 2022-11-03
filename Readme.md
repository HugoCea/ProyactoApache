# Proyecto Apache

Para realizar la comprobación del HTML y del PHP necesitaremos 3 archivos: **docker-compose**, **index.html**, **prueba.php**.

El _docker-compose_ es el que levanta el servicio, mientras que los otros 2 archivos son un **_.html_** y un **_.php_** con un texto de prueba para la comprobación, estos 2 los meteremos en una carpeta aparte del _docker-compose_, a esta le llamamos **_html_**.

## Configuración del _docker-compose_

Aquí crearemos el servicio _asir_apache_, a este le asignaremos:

1. Un nombre
2. La imagen de apache PHP
3. El puerto
4. Los volumenes

> Realmente no necesitamos el segundo volumen, que es de la configuración, ya que eso es para algo posterior, para esta comprobación no es necesario.

Nos debería quedar así:
~~~
services:
  asir_apache:
    container_name: asir_apache
    image: php:7.2-apache
    ports:
      - 8080:80
    volumes:
      - ./html:/var/www/html
      - confApache:/etc/apache2
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


Mientras que para el ver el _.php_ ecribiremos lo siguiente:
>localhost:8080/prueba.php

De esta forma nos mostrara el contenido de _prueba.php_ que en este caso es la página de información de PHP.







