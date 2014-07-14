#  UMedida.pm - Registra o modifica los grupos de productos
#
#	Creado: 03/06/2014 
#	UM: 12/07/2014

package UMedida;

use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';

# Variables válidas dentro del archivo
my ($Codigo, $Nombre, $Descripcion, $Id, $Mnsj);	# Datos
my ($codigo, $nombre, $descripcion) ;	# Campos
my ($bReg, $bNvo) ; 	# Botones
my @datos = () ;		# Lista de grupos
my $tabla = 'Unidades' ;
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

  	# Inicializa variables
	my %tp = $ut->tipos();
	$Codigo = $Nombre = $Descripcion = '';

	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
	$vnt->title("Registra Unidades de Medida");
	$vnt->geometry("360x360+490+4"); # Tamaño y ubicación
	
	# Defime marcos
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => 'Unidades registradas');
	my $mDatos = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => 'Datos unidad');
	my $mBotones = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes y botón de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'UMedida'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');

	# Define Lista de datos
	my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe',
		-selectmode => 'single', -orient => 'horizontal', -width => 45,
		-command => sub { &modifica($esto) } );
	$esto->{'vLista'} = $listaS;
	
	# Define botones
	$bReg = $mBotones->Button(-text => "Registra", 
		-command => sub { &registra($esto, @grupo) } ); 
	$bNvo = $mBotones->Button(-text => "Agrega", 
		-command => sub { &agrega($esto, @grupo) } ); 
	my $bCan = $mBotones->Button(-text => "Cancela", 
		-command => sub { &cancela($esto) } );
	
	# Define campos para registro de datos del grupo
	$codigo = $mDatos->LabEntry(-label => " Código:   ", -width => 3,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000',
		-textvariable => \$Codigo );
	$nombre = $mDatos->LabEntry(-label => " Nombre:  ", -width => 20,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Nombre);
	$descripcion = $mDatos->LabEntry(-label => " Descripción: ", -width => 40,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Descripcion);
		
	@datos = muestraLista($esto);
	if (not @datos) {
		$Mnsj = "No hay unidades registradas." ;
	}
		
	# Dibuja interfaz
	$codigo->pack(-side => "top", -anchor => "nw");	
	$nombre->pack(-side => "top", -anchor => "nw");
	$descripcion->pack(-side => "left", -anchor => "nw");

	$bReg->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bNvo->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'right', -expand => 0, -fill => 'none');
	
	$listaS->pack();
	$mLista->pack(-expand => 1);
	$mDatos->pack(-expand => 1);	
	$mBotones->pack(-expand => 1);
	$mMensajes->pack(-expand => 1, -fill => 'both');
	
	# Inicialmente deshabilita botón Registra
	$bReg->configure(-state => 'disabled');
	$codigo->focus;

	bless $esto;
	return $esto;
}

# Funciones internas
sub muestraLista ( $ ) 
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos de unidades registradas
	my @data = $bd->datosGU($tabla);

	# Completa TList con nombres de los grupos
	my ($algo, $nm);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$nm = sprintf("%-5s %-30s", $algo->[0], decode_utf8($algo->[1]) ) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$nm" ) ;
	}
	# Devuelve una lista de listas de unidades
	return @data;
}

sub modifica ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	my $bd = $esto->{'baseDatos'};
		
	$Mnsj = " ";
	if (not @datos) {
		$Mnsj = "NO hay datos para modificar.";
		return;
	}
	
	$bNvo->configure(-state => 'disabled');
	$bReg->configure(-state => 'active');
	
	# Obtiene unidad seleccionada
	my @ns = $listaS->info('selection');
	my $grupos = @datos[$ns[0]];
	
	# Rellena campos
	$Codigo = $grupos->[0];
	$Nombre =  decode_utf8( $grupos->[1] );
	$Descripcion =  $grupos->[2];
	$codigo->configure(-state => 'disabled');
	
	# Obtiene Id del registro
	$Id = $bd->idGU($Codigo,$tabla);
}

sub registra ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	$Mnsj = " ";
	# Convierte el código a mayúsculas
	$Codigo = uc Codigo ;
	# Comprueba registro del código
	if ($Codigo eq "") {
		$Mnsj = "Falta Código.";
		$codigo->focus;
		return;
	}
	# Verifica que se completen datos del grupo
	if ($Nombre eq "") {
		$Mnsj = "Debe tener un nombre.";
		$nombre->focus;
		return;
	}

	# Graba datos
	$bd->grabaGU($Codigo, $Nombre, $Descripcion, $Id, $tabla);

	# Muestra lista actualizada de grupos
	@datos = muestraLista($esto);
	
	limpiaCampos();
	
	$bNvo->configure(-state => 'active');
	$bReg->configure(-state => 'disabled');
}

sub agrega ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	$Mnsj = " ";
	# Convierte el código a mayúsculas
	$Codigo = uc $Codigo ;
	# Comprueba registro del código
	if ($Codigo eq "") {
		$Mnsj = "Debe registrar Código.";
		$codigo->focus;
		return;
	}
	# Verifica codigo no duplicado
	my $rid = $bd->idGU($Codigo,$tabla);
	if ($rid) {
		$Mnsj = "Código duplicado.";
		$codigo->focus;
		return;
	} 
	# Verifica que se completen datos
	if ($Nombre eq "") {
		$Mnsj = "Debe registrar un nombre.";
		$nombre->focus;
		return;
	}

	# Graba datos
	$bd->agregaGU($Codigo, $Nombre, $Descripcion, $tabla);

	# Muestra lista modificada de unidades
	@datos = muestraLista($esto);
	
	limpiaCampos();
	$codigo->focus;
}

sub limpiaCampos
{
	$codigo->delete(0,'end');
	$nombre->delete(0,'end');
	$descripcion->delete(0,'end');
	$Codigo = $Nombre = $Descripcion = '';
	$codigo->configure(-state => 'normal');
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	
	$vn->destroy();
}

# Fin del paquete
1;
