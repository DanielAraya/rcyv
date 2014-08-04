#!/usr/bin/perl -w

#  central.pl - inicio del programa 
#	Programa de Registro de Compras y Ventas para negocios tipo cafetería
#  
#	Creado : 02/06/2014
#	UM : 03/08/2014 

use prg::BaseDatos;
use strict;
use subs qw/opConfigura opRegistra opConsulta/;

use Tk ;
use Tk::BrowseEntry ;
use prg::Utiles ;
use Encode 'decode_utf8' ;
use Date::Simple ('ymd','today');
use YAML::Tiny ;

my $config = YAML::Tiny->new ;
$config = YAML::Tiny->read('config.yml');

my @aa = split /-/, today() ; # Fecha del día como arreglo

my $version = " central.pl v 0.4 al 16/06/2014";
my $pv = sprintf("Perl %vd", $^V) ;

# Define variables básicas
my ($bd,$prd,$vnt,$Titulo,$base,$lt,$lp,$lg,$lu,$TipoL,$pIva);
$TipoL = '';
$prd = $aa[0] ; # Extrae el año en curso
$Titulo = $config->[0]->{Empresa} ;
$pIva = $config->[0]->{Iva} / 100 ;

$base = "data/$prd.db3";
$bd = BaseDatos->crea($base);

# Crea la ventana principal
my $vp = MainWindow->new();
# Habilita acceso a rutinas utilitarias
my $ut = Utiles->crea($vp);

$version .= "\n con $pv, Tk $Tk::version y ";
$version .= "SQLite $bd->{'baseDatos'}->{sqlite_version} en $^O\n";
print "\nIniciando Programa Registro de Compras y Ventas\n$version";

# Creación de la interfaz gráfica
my %tp = $ut->tipos();
# Define y prepara la tamaño y ubicación de la ventana
$vp->geometry("480x435+2+2");
$vp->resizable(1,1);
$vp->title("Registro de Compras y Ventas");

# Define marco para mostrar información
my $mt = $vp->Scrolled('Text', -scrollbars=> 'e', -bg=> '#F2FFE6',
	-wrap => 'word');
$mt->tagConfigure('negrita', -font => $tp{ng}, -foreground => '#008080' ) ;
$mt->tagConfigure('grupo', -font => $tp{gr}, -foreground => 'brown') ;
$mt->tagConfigure('subt', -font => $tp{fx}, -foreground => 'blue') ;
$mt->tagConfigure('cuenta', -font => $tp{cn} ) ;
$mt->tagConfigure('detalle', -font => $tp{mn} ) ;
#print $mt->fontFamilies;

# Define marcos
my $marcoBM = $vp->Frame(-borderwidth => 2, -relief => 'raised'); # Menú
my $marcoAyd = $vp->Frame(-borderwidth => 1); # Ayuda
my $marcoT = $vp->Frame(-borderwidth => 1);  # Título  
                  
# Define botones de menú
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

# Contenido título
my $cEmpr = $marcoT->Label(-textvariable => \$Titulo, -bg => '#FEFFE6', 
		-fg => '#800000',);

# Dibuja la interfaz gráfica
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
# Título
$cEmpr->pack(-side => 'left', -expand => 1, -fill => 'x');
# opciones adicionales
$lst->pack(-side => "left", -anchor => "e");
$lt->pack(-side => "left", -anchor => "e");
$lp->pack(-side => "left", -anchor => "e");
$lg->pack(-side => "left", -anchor => "e");
$lu->pack(-side => "left", -anchor => "e");

my @dataP = $bd->datosP();
if (not @dataP) {
	$ut->ayuda($mt,'I');
}

# Ejecuta el programa
MainLoop;

# Subrutinas que definen el contenido de los menues
sub opConfigura {
[['command' => "Productos", -command => sub { require prg::DatosP;
	DatosP->crea($vp, $bd, $ut, $mt); } ],
 ['command' => "Grupos", -command => sub { require prg::Grupos; 
	Grupos->crea($vp, $bd, $ut, $mt ); } ], 
 ['command' => "Unidades", -command => sub { require prg::UMedida;
	UMedida->crea($vp, $bd, $ut, $mt); } ], "-",
 ['command' => "Menú", -command => sub { require prg::Menu;
	Menu->crea($vp, $bd, $ut, $mt); } ] ]
}

sub opRegistra {
[['command' => "Compra insumos", -command => sub { require prg::Compras;
	Compras->crea($vp, $bd, $ut, $mt, $pIva); } ],
 ['cascade' => "Otras compras", -tearoff => 0, -menuitems => opOtras() ], 
 ['cascade' => "Devoluciones", -tearoff => 0, -menuitems => opDevuelve()], 
 "-", 
 ['command' => "Comandas", -command => sub { require prg::Comandas; 
	Comandas->crea($vp, $bd, $ut, $mt ); } ],
 ['command' => "Ventas", -command => sub { require prg::Ventas; 
	Ventas->crea($vp, $bd, $ut, $mt ); } ], 
 "-",
 ['command' => "Proveedores", -command => sub { require prg::DatosT;
	DatosT->crea($vp, $bd, $ut, $mt); } ] ]
}

sub opOtras {
[['command' => "Factura", -command => sub { require prg::Gastos;
	Gastos->crea($vp, $bd, $ut, $mt, $pIva);} ], 
 ['command' => "Nota Crédito", -command => sub { require prg::NotaC;
 	NotaC->crea($vp, $bd, $ut, $mt, $pIva);} ]]
}

sub opDevuelve {
[['command' => "Emite ND", -command => sub { require prg::EmiteND;
	EmiteND->crea($vp, $bd, $ut, $mt);} ], 
 ['command' => "Registra NC", -command => sub { require prg::RegistraNC;
 	RegistraNC->crea($vp, $bd, $ut, $mt);} ]]
}

sub opConsulta {
[ ['command' => "Resultados", -command => sub { require prg::Resultado;
 	Resultado->crea($vp, $mt, $ut, $bd);} ], 
  ['cascade' => "Resúmenes", -tearoff => 0, -menuitems => opResumen() ],
  ['cascade' => "Estadísticas", -tearoff => 0, -menuitems => opEstadis() ] ,
   '-',
   ['cascade' => "Listados", -tearoff => 0, -menuitems => opListas()] ]
}

sub opResumen {
[['command' => "Caja", -command => sub { require prg::RCaja;
	RCaja->crea($vp, $mt, $ut, $bd);} ], "-",
['command' => "Compras", -command => sub { require prg::RCompras;
	RCompras->crea($vp, $mt, $ut, $bd);} ], 
 ['command' => "Ventas", -command => sub { require prg::RVentas;
 	RVentas->crea($vp, $mt, $ut, $bd);} ] ]
}

sub opEstadis {
[['command' => "Compras", -command => sub { require prg::ECompras;
	ECompras->crea($vp, $mt, $ut, $bd);} ], 
 ['command' => "Ventas", -command => sub { require prg::EVentas;
 	EVentas->crea($vp, $mt, $ut, $bd);} ]]
}

sub opListas {
[['command' => "Libro Compras", -command => sub { require prg::LCompras;
	LCompras->crea($vp, $mt, $ut, $bd, $Titulo);} ], 
 ['command' => "Guías Despacho", -command => sub { require prg::GDespacho;
 	GDespacho->crea($vp, $mt, $ut, $bd);} ]]
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

# Termina la ejecución del programa
exit (0);
