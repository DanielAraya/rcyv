RCyV
====

Un sistema registro de control de compras y ventas, pensado en pequeños 
tipo cafeterías.


##Descripción

Este programa está basado en las condiciones legales existentes en Chile,
en especial respecto de las normas tributarias. 

##Requisitos

+ Perl 5.8 o superior
+ Tk804
+ Módulos Perl 
  - DBD::SQLite
  - Tk::TableMatrix
  - Tk::BrowseEntry
  - Date::Simple
  - Number::Format
  - PDF::API2
+ Cualquier sistema operativo que soporte lo anterior.


##Instalación, configuracion y uso

### Requerimientos previos

+ Tener instalados todos los programas definidos como *Requisitos*
+ Disponer del programa *git*. En el sitio [github][] se pueden consultar
las guías sobre cómo instalarlo en los distintos sistemas operativos. En  
el caso de Linux están disponibles las interfaces gráficas que permiten 
instalar paquetes y programas.


   [github]: http://github.com/guides/home


### Verificar los requisitos

Luego de haber cambiado de directorio, ejecutar el comando

	perl modulos.pl
	
Esto permitirá verificar que estén instalados todos los módulos Perl que
necesita el programa *Quipu*. Si falta alguno, deberá ser instalado antes 
de seguir con la configuración. Se puede usar el programa `cpan` o alguna
interfaz gráfica disponible en el sistema operativo.


### Uso del programa

El programa se inicia, desde el directorio *Quipu*, con el comando:

	./central.pl &

Se puede crear un icono en el escritorio, siguiendo los procedimientos 
usuales del sistema operativo en que se instala el programa.


### Actualización del programa

Las actualizaciones del programa se obtienen desde Internet ejecutando 
el comando

	git pull
	
en el directorio *Quipu*. Para estar informado de los cambios realizados 
en el programa, enviar sus datos al correo indicado al final.

##Licencia

###Declaración de Principios

Este programa informático no es una mercancía: es libre y gratuito. Por 
tratarse de un programa de código abierto, puede ser modificado, utilizado 
y distribuido en las condiciones, mínimamente restrictivas, definidas en 
esta Licencia.

Los intercambios que pueda generar, quedan sujetos a los principios de 
reciprocidad y retribución del trabajo efectivamente realizado. Por ello,
este programa *no* está sujeto a una transacción mercantil.


###Condiciones de Uso y Distribución

Está permitido:

1. Hacer y entregar copias de este programa sin restricción,
   con la obligación de incluir el presente documento y 
   traspasar a terceros los derechos previstos en esta Licencia.

2. Realizar modificaciones al programa, dejando constancia en 
   los archivos respectivos quién, cómo y cuándo realizó la
   modificación, con la obligación de cumplir alguna de las 
   siguientes condiciones:

	>  a. Dejar las modificaciones libremente disponibles a otros usuarios, enviándolas al autor del programa original.
      
	>  b. Utilizarlas exclusivamente en forma personal o dentro de la organización en la cual se está usando el programa.
      
	>  c. Hacer un acuerdo directo con el autor de este programa.

3. Cobrar un honorario razonable por instalar, configurar y
   dar soporte en el uso de este programa, dejando constancia
   expresa que el código es libre y gratuito.

4. Utilizar las rutinas y algoritmos incluidos en el Programa,
   como parte de otro programa libre y gratuito.

NO está permitido:

1. Vender el programa, como tal. La retribución que se puede
   obtener es por el trabajo propio, no por el producto de un
   trabajo ajeno.

2. Utilizar el programa como parte de otro sistema informático
   sujeto a distribución comercial.


###Limitación de Responsabilidad

Este programa ha sido desarrollado con la idea de ser útil, pero se 
distribuye 'tal como está', sin garantía alguna, ya  sea directa o 
indirecta, respecto de algún uso particular o del rendimiento y calidad 
del trabajo efectuado con él.

(c) Daniel Araya R., 2014 - <daniel@geoarq.cl>
