#!/usr/bin/perl -w

#  creaTablas.pl - inicializa la base de datos con SQLite 3
#	Progama de Registro de Compras y Ventas
#	Se ejecuta indicado el año como dato de entrada
#
#	Creación : 02.06.2014
#	UM : 08.07.2014 

use DBI;
use strict;

my $prd = $ARGV[0]; # Nombre de la base de datos (año)
if (not $prd) {
	 print "Falta indicar año\n";
	 exit 1 ;
}
# Crea subdirectorios
my $emp = "data"; # directorio de datos 
if (not -d $emp) { # Verifica si existe el directorio
	mkdir $emp ;
	mkdir "$emp/txt";
	mkdir "$emp/csv";
	mkdir "$emp/pdf";
}

# Conecta a la base de datos
my $base = "$emp/$prd.db3";
if (-e $base ) {
	print "$base ya existe\n"; 
	exit 1 ;
}

my $bd = DBI->connect( "dbi:SQLite:$base" ) || 
	die "Imposible establecer conexión: $DBI::errstr";

### Crea tablas

# Proveedores
$bd->do("CREATE TABLE Proveedores (
	RUT char(10) NOT NULL PRIMARY KEY,
	Nombre char(35),
	Direccion char(40),
	Comuna char(20),
	Fecha_R char(10) )" );

# Unidades de Medida
$bd->do("CREATE TABLE Unidades (
	Codigo char(2),
	Nombre char(20),
	Descripcion char(40) )" );

# Grupos de productos
$bd->do("CREATE TABLE Grupos (
	Codigo char(2) NOT NULL PRIMARY KEY,
	Nombre char(30),
	Descripcion char(40) )" );

# Productos
$bd->do("CREATE TABLE Productos (
	Codigo char(4) NOT NULL PRIMARY KEY,
	Nombre char(35),
	Grupo char(2),
	UM char(2) )" );

# Comprobante de Compra
$bd->do("CREATE TABLE Compras (
	Numero int(5),
	RutP char(10),
	Fecha char(10),
	Tipo char(1),
	Factura char(10),
	Total int(8),
	Neto int(7),
	IVA int(7) )" );

# Detalle Compras
$bd->do("CREATE TABLE ItemsC (
	Numero int(5),
	CodigoP char(4),
	Cantidad int(4),
	UnidadM char(2),
	ValorT int(7),
	ValorU int(5) )" );

# Desconecta la base de datos
$bd->disconnect;
