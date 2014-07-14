#  DatosT.pm - Registra o modifica datos de Proveedores
#  
# 	Creado : 02/06/2014 
#	UM : 12/07/2014

package DatosT;

use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';
	
# Variables v�lidas dentro del archivo
my ($Nombre, $Rut, $Direccion, $Comuna, $Fecha, $Mnsj);
my ($nombre, $rut, $direc, $comuna ) ;		# Campos
my ($bReg, $bNvo) ; 	# Botones
my @datos = () ;		# Lista de Proveedores
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

	my %tp = $ut->tipos();
	$Nombre = $Direccion = $Comuna = $Rut = '';
	$Fecha = $ut->fechaHoy();
	
	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
	my $alt = 400 ; # $^O eq 'MSWin32' ? 400 : 430 ;
	$vnt->title("Agrega o Modifica Datos de Proveedores");
	$vnt->geometry("360x$alt+490+4"); # Tama�o y ubicaci�n
	
	# Defime marcos
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Proveedores registrados");
	my $mDatos = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Datos Proveedor");
	my $mBotones = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes y bot�n de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'DatosT'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');
	
	# Define Lista de datos
	my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe', -width => 45,
		-selectmode => 'single', -orient => 'horizontal', -font => $tp{mn}, 
		-command => sub { &modifica($esto) } );
	$esto->{'vLista'} = $listaS;
	
	# Define botones
	$bReg = $mBotones->Button(-text => "Registra", 
		-command => sub { &registra($esto) } ); 
	$bNvo = $mBotones->Button(-text => "Agrega", 
		-command => sub { &agrega($esto) } ); 
	my $bCan = $mBotones->Button(-text => "Cancela", 
		-command => sub { &cancela($esto) } );
	
	# Define campos para registro de datos del cliente o proveedor
	$rut = $mDatos->LabEntry(-label => "RUT:        ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Rut );
	$nombre = $mDatos->LabEntry(-label => "Nombre:   ", -width => 35,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Nombre);
	$nombre->bind("<FocusIn>", sub { &buscaRUT($esto) } );
	$direc = $mDatos->LabEntry(-label => "Direcci�n: ", -width => 40,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Direccion);
	$comuna = $mDatos->LabEntry(-label => "Comuna:   ", -width => 20,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Comuna);
	
	@datos = muestraLista($esto);
	if (not @datos) {
		$Mnsj = "No hay registros de proveedores." ;
	}
		
	# Dibuja interfaz
	$rut->grid(-row => 0, -column => 0,-columnspan => 4, -sticky => 'nw');	
	$nombre->grid(-row => 1, -column => 0,-columnspan => 4, -sticky => 'nw');
	$direc->grid(-row => 2, -column => 0,-columnspan => 4, -sticky => 'nw');
	$comuna->grid(-row => 3, -column => 0,-columnspan => 4, -sticky => 'nw');

	$bReg->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bNvo->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'right', -expand => 0, -fill => 'none');
	
	$listaS->pack();
	$mLista->pack(-expand => 1);
	$mDatos->pack(-expand => 1);	
	$mBotones->pack(-expand => 1);
	$mMensajes->pack(-expand => 1, -fill => 'both');
	
	# Inicialmente deshabilita bot�n Registra
	$bReg->configure(-state => 'disabled');
	$rut->focus;
	
	bless $esto;
	return $esto;
}

# Funciones internas
sub buscaRUT ($ ) {

	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $ut = $esto->{'mensajes'};
	
	if ( $bReg->cget('-state') eq 'active' ) { return ;}

	$Mnsj = " ";
	if (not $Rut) {
		$Mnsj = "Debe registrar un RUT.";
		$rut->focus;
		return;
	}
	$Rut = uc($Rut);
	$Rut =~ s/^0// ; # Elimina 0 al inicio
	if ( not $ut->vRut($Rut) ) {
		$Mnsj = "RUT no es v�lido.";
		$rut->focus;
	} else {
		my $nmb = $bd->buscaT($Rut);
		if ( $nmb) {
			$Mnsj = "Ese RUT ya est� registrado.";
			$rut->focus;
		}
	}
	return;
}

sub muestraLista ($ ) 
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos registrados
	my @data = $bd->datosT();

	# Completa TList con nombres de los terceros
	my ($algo, $nm);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$nm = sprintf("%10s %-35s", $algo->[0], decode_utf8($algo->[1])) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$nm" ) ;
	}
	# Devuelve una lista de listas con datos
	return @data;
}

sub modifica ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	
	$Mnsj = " ";
	if (not @datos) {
		$Mnsj = "NO hay datos para modificar";
		return;
	}
	
	$bNvo->configure(-state => 'disabled');
	$bReg->configure(-state => 'active');
	
	# Obtiene proveedor o cliente seleccionado
	my @ns = $listaS->info('selection');
	my $socio = @datos[$ns[0]];
	
	# Rellena campos
	$Rut =  $socio->[0];
	$Nombre = decode_utf8($socio->[1]);
	$Direccion = decode_utf8($socio->[2]);
	$Comuna = decode_utf8($socio->[3]);

	# Impide modificar RUT
	$rut->configure(-state => 'disabled');
}

sub registra ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	# Verifica que se completen datos
	$Mnsj = " ";
	if ($Nombre eq "") {
		$Mnsj = "Debe registrar un nombre.";
		$nombre->focus;
		return;
	}
#	if ($Direccion eq "") {
#		$Mnsj = "Falta la direcci�n.";
#		$direc->focus;
#		return;
#	}
#	if ($Comuna eq "") {
#		$Mnsj = "Indicar comuna.";
#		$comuna->focus;
#		return;
#	}

	# Graba datos
	$bd->grabaDatosT($Rut,$Nombre,$Direccion,$Comuna);

	# Muestra lista actualizada de registros
	@datos = muestraLista($esto);

	limpiaCampos();
	
	$rut->configure(-state => 'normal');
	$bNvo->configure(-state => 'active');
	$bReg->configure(-state => 'disabled');
	$rut->focus;
}

sub agrega ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	# Comprueba RUT
	$Mnsj = " ";
	if ($Rut eq "") {
		$Mnsj = "Debe registrar el RUT.";
		$rut->focus;
		return;
	}
	# Verifica que se completen datos
	if ($Nombre eq "") {
		$Mnsj = "Debe registrar un nombre.";
		$nombre->focus;
		return;
	}
#	if ($Direccion eq "") {
#		$Mnsj = "Falta la direcci�n.";
#		$direc->focus;
#		return;
#	}
#	if ($Comuna eq "") {
#		$Mnsj = "Falta indicar la comuna.";
#		$comuna->focus;
#		return;
#	}

	# Graba datos
	$bd->agregaT($Rut,$Nombre,$Direccion,$Comuna,$Fecha);

	# Muestra lista modificada de registros
	@datos = muestraLista($esto);
	limpiaCampos();
	$rut->focus;
}

sub limpiaCampos( )
{
	$rut->delete(0,'end');
	$nombre->delete(0,'end');
	$direc->delete(0,'end');
	$comuna->delete(0,'end');
	$Nombre = $Rut = $Direccion = $Comuna = '';
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	
	$vn->destroy();
}

# Fin del paquete
1;
