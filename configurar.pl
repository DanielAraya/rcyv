#!/usr/bin/perl -w

#  configurar.pl - Define parámetros básicos, agrega y configura empresas
#  Forma parte del programa Quipu
#
#  Derechos de autor: Víctor Araya R., 2009
#  
#  Puede ser utilizado y distribuido en los términos previstos en la 
#  licencia incluida en este paquete 
#  UM: 26.05.2014

use prg::BaseDatos;
use Tk;
use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';

use prg::Utiles;

my ($nbd, $Nombre, $Rut, $Mnsj, $Prd, $Multi, $ne, $IVA, $base, $Cierre); # Variables
my ($nombre, $rut, $prd, $multi, $iva, $cierre ); # Campos
my ($bCan, $bNvo, $bAct) ; # Botones
my @datos = () ;	# Lista de empresas
$nbd = 'datosG.db3' ;
if (not -e $nbd) {
	creaDatosG();
}		
my $bd = BaseDatos->crea($nbd);
my @cnf = $bd->leeCnf();
$Prd = $cnf[0];
$Multi = $cnf[3];
$IVA = $cnf[4];
$Cierre = $cnf[5];
$Nombre = $Rut = '';
$base = "$cnf[0].db3" ;

# Define ventana
my $vnt = MainWindow->new();
$vnt->title("Configura Programa Quipu");
$vnt->geometry("370x390+2+2"); # Tamaño y ubicación
my $ut = Utiles->crea($vnt);
my $esto = {};
$esto->{'baseDatos'} = $bd;
$esto->{'mensajes'} = $ut;

my %tp = $ut->tipos();
# Defime marcos
my $mParametros = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
	-label => 'Datos iniciales');
my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
	-label => 'Empresas creadas');
my $mDatos = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
	-label => 'Datos empresa');
my $mBtns = $vnt->Frame(-borderwidth => 1);
my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

# Barra de mensajes y botón de ayuda
my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{fx},
	-bg => '#F2FFE6', -fg => '#800000',);
$mnsj->pack(-side => 'left', -expand => 1, -fill => 'x');
$Mnsj = "Mensajes de error o advertencias.";

# Define Lista de datos
my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe', -width => 65,
	-selectmode => 'single', -orient => 'horizontal', -font => $tp{mn}, 
	-height => 12, -command => sub { &configura($esto);} );
$esto->{'vLista'} = $listaS;

# Define botones
$bNvo = $mBtns->Button(-text => "Agrega", -command => sub { &agrega($esto)}); 
$bCan = $mBtns->Button(-text => "Termina", 
	-command => sub { $vnt->destroy(); $bd->cierra();});
$bCfg = $mBtns->Button(-text => "Configura", 
	-command => sub { &datos() });
$bAct = $mBtns->Button(-text => "Actualiza", 
	-command => sub { $bd->actualizaCnf($Multi,$Prd,$IVA,$Cierre) });

# Parametros
$prd = $mParametros->LabEntry(-label => " Inicio", -width => 5,
	-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
	-textvariable => \$Prd );
$iva = $mParametros->LabEntry(-label => "  IVA", -width => 3,
	-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
	-textvariable => \$IVA );
$cierre = $mParametros->LabEntry(-label => "  Cierre", -width => 5,
	-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
	-textvariable => \$Cierre );
$multi = $mParametros->Checkbutton(-variable => \$Multi, 
		 -text => "Multiempresa",);
# Define campos para registro de datos de la empresa
$rut = $mDatos->LabEntry(-label => "RUT:   ", -width => 12,
	-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
	-textvariable => \$Rut );

$nombre = $mDatos->LabEntry(-label => "Razón Social: ", -width => 35,
	-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
	-textvariable => \$Nombre);
$nombre->bind("<FocusIn>", sub { &buscaRUT($esto) } );

# Dibuja interfaz
$mMensajes->pack(-expand => 1, -fill => 'both');
$prd->pack(-side => 'left', -expand => 0, -fill => 'none');
$iva->pack(-side => 'left', -expand => 0, -fill => 'none');
$cierre->pack(-side => 'left', -expand => 0, -fill => 'none');
$multi->pack(-side => 'left', -expand => 0, -fill => 'none');
$rut->grid(-row => 0, -column => 0, -columnspan => 2, -sticky => 'nw');	
$nombre->grid(-row => 1, -column => 0, -columnspan => 2, -sticky => 'nw');

$bNvo->pack(-side => 'left', -expand => 0, -fill => 'none');
$bCfg->pack(-side => 'left', -expand => 0, -fill => 'none');
$bAct->pack(-side => 'left', -expand => 0, -fill => 'none');
$bCan->pack(-side => 'right', -expand => 0, -fill => 'none');

$mParametros->pack(-expand => 1);
$listaS->pack();
$mLista->pack(-expand => 1);
$mDatos->pack(-expand => 1);	
$mBtns->pack(-expand => 1);

@datos = &muestraLista($esto, $bd);
$ne = @datos; # Número de empresas
if (not $ne) {
	$Mnsj = "No hay registros" ;
}

# Ejecuta el programa
MainLoop;

# Funciones internas
sub buscaRUT ($) {

	my ($esto) = @_;
	my $ut = $esto->{'mensajes'};
	my $bd = $esto->{'baseDatos'};

	$Mnsj = " ";
	if (not $Rut) {
		$Mnsj = "Debe registrar un RUT";
		$rut->focus;
		return;
	}
	if ( not $ut->vRut($Rut) ) {
		$Mnsj = "RUT no es válido";
		$rut->focus;
	} else {
		if ( $bd->buscaE($Rut)) {
			$Mnsj = "Ese RUT ya esta registrado.";
			$rut->focus;
		}
	}
	return;
}

sub muestraLista ($ $) 
{
	my ($esto, $bd ) = @_;
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos de las empresas
	my @data = $bd->listaEmpresas();

	# Completa TList con nombres y rut de la empresas
	my ($algo, $nm);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$nm = sprintf("%10s %-32s", $algo->[0], decode_utf8($algo->[1]) ) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$nm" ) ;
	}
	# Devuelve una lista de listas con datos
	return @data;
}

sub agrega ()
{
	my ($esto) = @_;

	$bd->cierra();
	$bd = BaseDatos->crea($nbd);
	# Comprueba RUT
	$Mnsj = " ";
	if ($Rut eq "") {
		$Mnsj = "Debe registrar RUT de la Empresa.";
		$rut->focus;
		return;
	} else {
		if ( $bd->buscaE($Rut)) {
			$Mnsj = "Esa empresa ya está registrada.";
			return ;
		}		
	}
	# Verifica que se completen datos
	if ($Nombre eq "") {
		$Mnsj = "Debe registrar un nombre";
		$nombre->focus;
		return;
	}
	if ($Prd eq "") {
		$Mnsj = "Indique año inicial";
		$prd->focus;
		return;
	}

	# Graba datos
	$bd->agregaE($Rut,$Nombre,$Multi,$Prd);
	$bd->grabaCnf($Multi,$Prd,$IVA,$Cierre) if not $ne ;
	# Crea tablas
	creaTablasRC($Rut,$Prd) ;

	@datos = muestraLista($esto,$bd);
	$ne = @datos;
	
	$rut->delete(0,'end');
	$nombre->delete(0,'end');
	$Nombre = $Rut = '';
	$rut->focus;
}

sub configura ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	my $bd = $esto->{'baseDatos'};
	
	$Mnsj = " ";		
	# Obtiene datos de la empresa seleccionada
	my @ns = $listaS->info('selection');
	my $emp = @datos[$ns[0]];
	
	# Rellena campos
	$Nombre = decode_utf8($emp->[1]);
	$Rut =  $emp->[0];
	
}

sub datos
{
	if ($Rut eq '' ) {
		$Mnsj = "Seleccione una empresa.";
		return ;		
	}
	$bd->cierra();
	$bd = BaseDatos->crea("$Rut/$base");
	$bd->anexaBD();
	require prg::DatosE; 
	DatosE->crea($vnt, $bd, $ut, $Rut);
	
}

sub creaDatosG
{
	use DBI;
	use strict;
	
	# EMPRESAS y DATOS COMUNES
	# Conecta a la base de datos
	my $bd = DBI->connect( "dbi:SQLite:datosG.db3" ) || 
		die "Imposible establecer conexión: $DBI::errstr";
	
	# Datos empresas
	$bd->do("CREATE TABLE Config (
		Periodo int(4),
		PlanC int(1),
		InterE int(1),
		MultiE int(1),
		IVA int(2),
		Cierre char(5) )" );
	
	$bd->do("CREATE TABLE DatosE (
		Nombre text(30),
		Rut char(10),
		Giro text(35),
		RutRL char(10),
		NombreRL text(30),
		OtrosI int(1),
		BltsCV int(1),
		CBanco int(1),
		CCostos int(1),
		CPto int(1),
		Datos int(1),
		Inicio int(4) )" );
	
	# Plan de Cuentas
	$bd->do("CREATE TABLE Cuentas (
		Codigo char(5) NOT NULL PRIMARY KEY,
		Cuenta text(35),
		SGrupo char(2),
		ImptoE char(1),
		CuentaI char(1),
		Negativo char(1) )" );
	
	# Subgrupos
	$bd->do("CREATE TABLE SGrupos (
		Codigo char(5) NOT NULL PRIMARY KEY,
		Nombre text(35),
		Grupo char(1) )" );
		
	$bd->do("INSERT INTO SGrupos VALUES('10','Disponible','A') ");
	$bd->do("INSERT INTO SGrupos VALUES('11','Realizable','A') ");
	$bd->do("INSERT INTO SGrupos VALUES('20','Corto Plazo','P') ");
	$bd->do("INSERT INTO SGrupos VALUES('22','Patrimonio','P') ");
	$bd->do("INSERT INTO SGrupos VALUES('30','Ventas','I') ");
	$bd->do("INSERT INTO SGrupos VALUES('40','Gastos','G') ");
	
	# Documentos
	$bd->do("CREATE TABLE Documentos (
		Codice char(2) NOT NULL PRIMARY KEY,
		Nombre char(15),
		CTotal char(5),
		CIva char(5) )" );
	
	$bd->do("INSERT INTO Documentos VALUES('FV','F.Venta','','') ");
	$bd->do("INSERT INTO Documentos VALUES('FC','F.Compra','','') ");
	$bd->do("INSERT INTO Documentos VALUES('FE','FCT.Emitida','','') ");
	$bd->do("INSERT INTO Documentos VALUES('FR','FCT.Recibida','','') ");
	$bd->do("INSERT INTO Documentos VALUES('BH','B.Honorario','','') ");
	$bd->do("INSERT INTO Documentos VALUES('NC','N.Crédito','','') ");
	$bd->do("INSERT INTO Documentos VALUES('ND','N.Débito','','')");
	$bd->do("INSERT INTO Documentos VALUES('CH','Cheque','','')");
	$bd->do("INSERT INTO Documentos VALUES('LT','Letra','','')");
	$bd->do("INSERT INTO Documentos VALUES('DB','Depósito','','')");
	
	# Desconecta la base de datos
	$bd->disconnect;	
}

sub creaTablasRC($ $)
{
	use DBI;
	use strict;
	
	my ($emp, $prd ) = @_ ;
	
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
		return ;
	}
	my $bd = DBI->connect( "dbi:SQLite:$base" ) || 
		die "Imposible establecer conexión: $DBI::errstr";
	
	# REGISTROS CONTABLES
	# Cuentas de mayor
	# Nota: Los campos 'TSaldo' y 'Saldo' corresponde a la apertura del año
	$bd->do("CREATE TABLE Mayor (
		Codigo char(5) NOT NULL PRIMARY KEY,
		Debe int(9) ,
		Haber int(9) ,
		Saldo int(9) ,
		TSaldo char(1) ,
		Fecha_UM char(10) )" );
	
	# Actualización de Fecha_UM en Cuenta de Mayor
	$bd->do("CREATE TRIGGER AFechaM AFTER UPDATE OF Debe, Haber ON Mayor
	  BEGIN
	    UPDATE Mayor SET Fecha_UM = substr(datetime('now'),0,10) 
		WHERE rowid = old.rowid ;
	  END" );
	
	# Encabezado del Comprobante de Contabilidad
	$bd->do("CREATE TABLE DatosC (
		Numero int(5),
		Glosa text(25),
		Fecha char(10),
		TipoC char(1),
		Total int(9),
		Anulado int(1), 
		Ref int(5) )" );
	
	# Líneas del Comprobante de Contabilidad
	$bd->do("CREATE TABLE ItemsC (
		Numero int(5),
		CuentaM char(5),
		Debe int(9),
		Haber int(9),
		Detalle char(15),
		RUT char(10),
		TipoD char(2),
		Documento char(10),
		CCosto char(3),
		Mes int(2) )" );
	
	# Contabiliza movimiento en Cuentas de Mayor
	$bd->do("CREATE TRIGGER Actualiza AFTER INSERT ON ItemsC
	  BEGIN
	    UPDATE Mayor SET Debe = Debe + new.Debe, Haber = Haber + new.Haber 
			WHERE Codigo = new.CuentaM ;
	  END" );
	
	# Facturas de Compras y Notas de Débito y Crédito de Proveedores
	# Campo Nulo: 0 Vigente; 1 Emitido como nulo; 2 Anulado luego de emitido
	# Similar para Ventas y BoletasH
	$bd->do("CREATE TABLE Compras (
		RUT char(10),
		Numero char(10),
		FechaE char(10),
		Total int(8),
		IVA int(8),
		Afecto int(8),
		Exento int(8),
		Comprobante int(5),
		FechaV char(10),
		Abonos int(8),
		Pagada int(1) ,
		FechaP char(10),
		Tipo char(2),
		Mes int(2),
		Nulo int(1),
		Cuenta int(4),
		TF char(1),
		Orden int(2),
		IEspec int(8),
		IRetenido int(8),
		DocPago char(15))" );
	
	# Actualización de Pagada en F. Compras
	$bd->do("CREATE TRIGGER PagoFC AFTER UPDATE OF Abonos ON Compras
	  BEGIN
	    UPDATE Compras SET Pagada = CASE WHEN Abonos == Total THEN 1
			ELSE 0 END ;
	  END" );
	
	# Facturas de Ventas y Notas de Débito y Crédito de Clientes
	$bd->do("CREATE TABLE Ventas (
		RUT char(10),
		Numero char(10),
		FechaE char(10),
		Total int(8),
		IVA int(8),
		Afecto int(8),
		Exento int(8),
		Comprobante int(5),
		FechaV char(10),
		Abonos int(8),
		Pagada int(1) ,
		FechaP char(10),
		Tipo char(2),
		Mes int(2),
		Nulo int(1),
		Cuenta int(4),
		TF char(1),
		Orden int(2),
		IEspec int(8),
		IRetenido int(8),
		DocPago char(15) )" );
	
	# Actualización de Pagada en F. Ventas
	$bd->do("CREATE TRIGGER PagoFV AFTER UPDATE OF Abonos ON Ventas
	  BEGIN
	    UPDATE Ventas SET Pagada = CASE WHEN Abonos == Total THEN 1
			ELSE 0 END ;
	  END " );
	
	# Boletas de Ventas
	$bd->do("CREATE TABLE BoletasV (
		Fecha char(10),
		De char(10),
		A char(10),
		Total int(8),
		IVA int(8),
		Comprobante int(5),
		Mes int(2) )" );
	
	# Boletas de Honorarios
	$bd->do("CREATE TABLE BoletasH (
		RUT char(10),
		Numero char(10),
		FechaE char(10),
		Total int(8),
		Retenido int(8),
		Comprobante int(5),
		FechaV char(10),
		Abonos int(8),
		Pagada int(1) ,
		FechaP char(10),
		Mes int(2),
		Nulo int(1),
		Cuenta int(4),
		DocPago char(15) )" );
	
	# Actualización de Pagada en B. Honorarios
	$bd->do("CREATE TRIGGER PagoBH AFTER UPDATE OF Abonos ON BoletasH
	  BEGIN
	    UPDATE BoletasH SET Pagada = CASE WHEN Abonos == Total - Retenido THEN 1 
			ELSE 0 END ;
	  END" );
	
	# Documentos emitidos (cheques y letras)
	$bd->do("CREATE TABLE DocsE (
		Numero char(10),
		Cuenta int(4) ,
		RUT char(10),
		FechaE char(10),
		Total int(8),
		Comprobante int(5),
		FechaV char(10),
		Abonos int(8),
		FechaP char(10),
		Estado char(1) ,
		Nulo int(1),
		Tipo char(2),
		DocPago char(15) )" );
	
	$bd->do("CREATE TRIGGER PagoDE AFTER UPDATE OF Abonos ON DocsE
	  BEGIN
	    UPDATE DocsE SET Estado = CASE WHEN Abonos == Total THEN 'P'
			ELSE Estado END ;
	  END " );
	
	# Documentos recibidos (cheques y letras)
	$bd->do("CREATE TABLE DocsR (
		Numero char(10),
		Cuenta int(4) ,
		RUT char(10),
		FechaE char(10),
		Total int(8),
		Comprobante int(5),
		FechaV char(10),
		Abonos int(8),
		FechaP char(10),
		Estado char(1) ,
		Nulo int(1),
		Tipo char(2),
		DocPago char(15) )" );
	
	$bd->do("CREATE TRIGGER PagoDR AFTER UPDATE OF Abonos ON DocsR
	  BEGIN
	    UPDATE DocsR SET Estado = CASE WHEN Abonos == Total THEN 'P'
			ELSE Estado END ;
	  END " );
	
	# Impuestos especiales
	$bd->do("CREATE TABLE ImptosE (
		Comprobante int(5),
		CuentaM char(5),
		Monto int(8),
		Anulado int(1) )" );
	
	# Cuentas Individuales (Clientes, Proveedores, Socios y Personal)
	$bd->do("CREATE TABLE CuentasI (
		RUT char(10) NOT NULL PRIMARY KEY,
		Debe int(9) ,
		Haber int(9) ,
		Saldo int(9) ,
		TSaldo char(1),
		Fecha_UM char(10) )" );
	
	# Actualización de Saldo, TSaldo y Fecha_UM en cuenta individual
	$bd->do("CREATE TRIGGER AFechaCI AFTER UPDATE OF Debe, Haber ON CuentasI
	  BEGIN
	    UPDATE CuentasI SET Fecha_UM = substr(datetime('now'),0,10) 
		WHERE rowid = old.rowid ;
	  END " );
	
	# DATOS ADICIONALES
	# Terceros: Socios, Clientes y Proveedores
	$bd->do("CREATE TABLE Terceros (
		RUT char(10) NOT NULL PRIMARY KEY,
		Nombre char(35),
		Direccion char(40),
		Comuna char(20),
		Fonos char(20),
		Cliente char(1),
		Proveedor char(1),
		Socio char(1), 
		Honorario char(1),
		Fecha_R char(10) )" );
	
	# Personal
	$bd->do("CREATE TABLE Personal (
		RUT char(10) NOT NULL PRIMARY KEY,
		Nombre char(35),
		Direccion char(40),
		Comuna char(20),
		Fonos char(12),
		FIngreso char(10),
		FRetiro char(10),
		Fecha_R char(10),
		CCosto char(3) )" );
	
	# Bancos
	$bd->do("CREATE TABLE Bancos (
		Codigo int(2) NOT NULL PRIMARY KEY,
		Nombre text(30),
		RUT char(10) )" );
		
	# Centros de Costos
	$bd->do("CREATE TABLE CCostos (
		Codigo char(3) NOT NULL PRIMARY KEY,
		Nombre text(30) ,
		Tipo char(1) ,
		Grupo char(1),
		Agrupa int(1) )" );
	
	# Desconecta la base de datos
	$bd->disconnect;

}
# Termina la ejecución del programa
exit (0);
