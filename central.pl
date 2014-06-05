#!/usr/bin/perl -w

#  central.pl - inicio del programa 
#	Programa de Registro de Compras y Ventas
#  
#	Creado : 02/06/2014
#	UM : 03/06/2014 

use prg::BaseDatos;
use strict;
use subs qw/opConfigura opRegistra opConsulta/;

use Tk ;
use Tk::BrowseEntry ;
use prg::Utiles ;
use Encode 'decode_utf8' ;
use Date::Simple ('ymd','today');

my @aa = split /-/, today() ; # Fecha del d�a como arreglo

my $version = "central.pl 0.5 al 03/06/2014";
my $pv = sprintf("Perl %vd", $^V) ;

# Define variables b�sicas
my ($bd,$prd,$vnt,$Titulo,$base,$lt,$lp,$lg,$lu,$TipoL);
$TipoL = '';
$prd = $aa[0] ; # Extrae el a�o en curso
$Titulo = 'Caf� & Canela';
$base = "data/$prd.db3";

$bd = BaseDatos->crea($base);

# Crea la ventana principal
my $vp = MainWindow->new();
# Habilita acceso a rutinas utilitarias
my $ut = Utiles->crea($vp);

$version .= " con $pv, Tk $Tk::version y ";
$version .= "SQLite $bd->{'baseDatos'}->{sqlite_version} en $^O\n";
print "\nIniciando Programa Registro de Compras\n$version";

# Creaci�n de la interfaz gr�fica
my %tp = $ut->tipos();
# Define y prepara la tama�o y ubicaci�n de la ventana
$vp->geometry("480x430+2+2");
$vp->resizable(1,1);
$vp->title("Registro de Compras");

# Define marco para mostrar informaci�n
my $mt = $vp->Scrolled('Text', -scrollbars=> 'e', -bg=> '#F2FFE6',
	-wrap => 'word');
$mt->tagConfigure('negrita', -font => $tp{ng}, -foreground => '#008080' ) ;
$mt->tagConfigure('grupo', -font => $tp{gr}, -foreground => 'brown') ;
$mt->tagConfigure('cuenta', -font => $tp{cn} ) ;
$mt->tagConfigure('detalle', -font => $tp{mn} ) ;
#print $mt->fontFamilies;

# Define marcos
my $marcoBM = $vp->Frame(-borderwidth => 2, -relief => 'raised'); # Men�
my $marcoAyd = $vp->Frame(-borderwidth => 1); # Ayuda
my $marcoT = $vp->Frame(-borderwidth => 1);  # T�tulo  
                  
# Define botones de men�
my $mConfigura = $marcoBM->Menubutton(-text => "Configura", -tearoff => 0, 
	-underline => 0, -indicatoron => 1, -menuitems => opConfigura);
my $mRegistro = $marcoBM->Menubutton(-text => "Registra", -tearoff => 0, 
	-underline => 0, -indicatoron => 1, -menuitems => opRegistra);
my $mConsulta = $marcoBM->Menubutton(-text => "Consulta", -tearoff => 0, 
	-underline => 0, -indicatoron => 1, -menuitems => opConsulta);
my $bFin = $marcoBM->Button(-text => "Termina", -relief => 'ridge',
	-command => sub { $vp->destroy();  $bd->cierra(); } );

my $lst = $marcoAyd->Label(	-text => "Muestra: ");
$lt = $marcoAyd->Radiobutton( -text => "Productos ", -value => 'Productos', 
		-variable => \$TipoL, -command => sub { &listados($TipoL) } );
$lp = $marcoAyd->Radiobutton( -text => "Proveedores", -value => 'Proveedores', 
		-variable => \$TipoL, -command => sub { &listados($TipoL) } );
$lg = $marcoAyd->Radiobutton( -text => "Grupos", -value => 'Grupos', 
		-variable => \$TipoL, -command => sub { &listados($TipoL) } );
$lu = $marcoAyd->Radiobutton( -text => "Unidades", -value => 'Unidades', 
		-variable => \$TipoL, -command => sub { &listados($TipoL) } );

# Contenido t�tulo
my $cEmpr = $marcoT->Label(-textvariable => \$Titulo, -bg => '#FEFFE6', 
		-fg => '#800000',);

# Dibuja la interfaz gr�fica
# marcos
$marcoT->pack(-side => 'top', -expand => 0, -fill => 'both');
$marcoBM->pack(-side => 'top', -expand => 0, -fill => 'both');
$mt->pack(-fill => 'both');
$marcoAyd->pack(-fill => 'both');
# botones         
$mConfigura->pack(-side => 'left', -expand => 0, -fill => 'none');
$mRegistro->pack(-side => 'left', -expand => 0, -fill => 'none');
$mConsulta->pack(-side => 'left', -expand => 0, -fill => 'none');
$bFin->pack(-side => 'right');
# T�tulo
$cEmpr->pack(-side => 'left', -expand => 1, -fill => 'x');
# opciones adicionales
$lst->pack(-side => "left", -anchor => "e");
$lt->pack(-side => "left", -anchor => "e");
$lp->pack(-side => "left", -anchor => "e");
$lg->pack(-side => "left", -anchor => "e");
$lu->pack(-side => "left", -anchor => "e");

# Ejecuta el programa
MainLoop;

# Subrutinas que definen el contenido de los menues
sub opConfigura {
[['command' => "Productos", -command => sub { require prg::DatosP;
	DatosP->crea($vp, $bd, $ut, '', $mt); } ],
 ['command' => "Grupos", -command => sub { require prg::Grupos; 
	Grupos->crea($vp, $bd, $ut, $mt ); } ], "-", 
 ['command' => "Unidades", -command => sub { require prg::UMedida;
	UMedida->crea($vp, $bd, $ut, $mt); } ] ]
}

sub opRegistra {
[['command' => "Compras", -command => sub { require prg::Compras;
	Compras->crea($vp, $bd, $ut, '', $mt); } ],
 ['command' => "Devoluciones", -command => sub { require prg::Devuelve; 
	Devuelve->crea($vp, $bd, $ut, $mt ); } ], "-", 
 ['command' => "Proveedores", -command => sub { require prg::DatosT;
	DatosT->crea($vp, $bd, $ut, $mt); } ] ]
}

sub opConsulta {
[ 
  ['command' => "Resumen compras", -command => sub { require prg::Resumen;
	Resumen->crea($vp, $mt, $bd, $ut);} ],
  ['command' => "Estad�sticas", -command => sub { require prg::Estadis;
	Estadis->crea($vp, $mt, $bd, $ut);} ] ]
}

sub listados ( $ )
{
	my ($lstd) = @_ ;
	my ($algo, $nm, @data);
	if ($lstd eq 'Proveedores' ) {
		@data = $bd->datosT();
	} 
	elsif ($lstd eq 'Productos') {
		@data = $bd->datosP();
	} 
	else {
		@data = $bd->datosGU($lstd);
	}
	$mt->delete('0.0','end');
	$mt->insert('end',"$lstd\n\n", 'grupo');
	foreach $algo ( @data ) {
		$nm = sprintf("%10s  %-35s", $algo->[0], decode_utf8($algo->[1])) ;
		$mt->insert('end', "$nm\n") ;
	}
}

# Termina la ejecuci�n del programa
exit (0);
