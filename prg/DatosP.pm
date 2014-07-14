#  DatosP.pm - Registra o modifica productos
#  
# 	Creado : 03/06/2014 
#	UM : 12/07/2014

package DatosP;

use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';
#use Data::Dumper ;

# Variables válidas dentro del archivo
my ($Nombre, $Codigo, $Grupo, $Unidad, $Mnsj, @listaU, @listaG, $GR, $UM);
my ($nombre, $codigo, $grupo, $um);	# Campos
my ($bReg, $bNvo) ; 	# Botones
my @datos = () ;		# Lista de Productos
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

	my %tp = $ut->tipos();
	$Nombre = $Codigo = $Grupo = $Unidad = '';
	
	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
#	my $alt = $^O eq 'MSWin32' ? 350 : 400 ;
	$vnt->title("Agrega o Modifica Datos de Productos");
	$vnt->geometry("360x360+490+4"); # Tamaño y ubicación
	
	# Defime marcos
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Productos registrados");
	my $mDatos = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Datos Producto");
	my $mBotones = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes y botón de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'DatosP'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');

	$Mnsj = "Para ver Ayuda presione botón 'i'.";
		
	# Define Lista de datos
	my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe', -width => 50,
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
	
	# Define campos para registro de datos del producto
	$codigo = $mDatos->LabEntry(-label => "Código: ", -width => 5,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Codigo );
	$nombre = $mDatos->LabEntry(-label => "Nombre: ", -width => 35,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Nombre);
	$nombre->bind("<FocusIn>", sub { &buscaCod($esto) } );
	my $grT = $mDatos->Label(-text => "Grupo ");
	$grupo = $mDatos->BrowseEntry( -variable => \$GR, -state => 'readonly',
		-disabledbackground => '#FFFFFC', -autolimitheight => 1,
		-disabledforeground => '#000000', -autolistwidth => 1,
		-browse2cmd => \&eligeG );
	@listaG = $bd->datosGU('Grupos');
#	print Dumper @listaG ;
	foreach $algo ( @listaG ) {
		$grupo->insert('end', decode_utf8($algo->[1]) ) ;
	}
	my $umT = $mDatos->Label(-text => "UM ");
	$um = $mDatos->BrowseEntry( -variable => \$UM, -state => 'readonly',
		-disabledbackground => '#FFFFFC', -autolimitheight => 1,
		-disabledforeground => '#000000', -autolistwidth => 1,
		-browse2cmd => \&eligeU );
	@listaU = $bd->datosGU('Unidades');
	foreach $algo ( @listaU ) {
		$um->insert('end', decode_utf8($algo->[1]) ) ;
	}
	
	@datos = muestraLista($esto);
	if (not @datos) {
		$Mnsj = "No hay registros de productos." ;
	}
		
	# Dibuja interfaz
	$codigo->grid(-row => 0, -column => 0, -columnspan => 6, -sticky => 'nw');	
	$nombre->grid(-row => 1, -column => 0, -columnspan => 6, -sticky => 'nw');
	$grT->grid(-row => 2, -column => 0, -columnspan => 6, -sticky => 'nw');
	$grupo->grid(-row => 2, -column => 1, -columnspan => 6, -sticky => 'nw');
	$umT->grid(-row => 3, -column => 0, -columnspan => 6, -sticky => 'nw');
	$um->grid(-row => 3, -column => 1, -columnspan => 6, -sticky => 'nw');

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
	# Comprueba que estén definidos los grupos y las unidades de medida
	if (not @listaG) { 
		$ut->mError('Debe registrar grupos de productos');
		$bNvo->configure(-state => 'disabled');
	}
	if (not @listaU) { 
		$ut->mError('Debe registrar unidades de medida');
		$bNvo->configure(-state => 'disabled');
	}
	if ( @listaG and @listaU ) {
		$codigo->focus;
	} else {
		$bCan->focus ;
	}
	
	bless $esto;
	return $esto;
}

# Funciones internas
sub buscaCod ( $ ) {

	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $ut = $esto->{'mensajes'};
	
	if ( $bReg->cget('-state') eq 'active' ) { return ;}

	$Mnsj = " ";
	if (not $Codigo) {
		$Mnsj = "Debe registrar un código.";
		$codigo->focus;
		return;
	}
	
	my $nmb = $bd->buscaP($Codigo);
	if ( $nmb) {
		$Mnsj = "Ese código ya está registrado.";
		$codigo->focus;
	}
	return;
}

sub muestraLista ($ ) 
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos registrados
	my @data = $bd->datosP();

	# Completa TList con nombres de los productos
	my ($algo, $nm);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$nm = sprintf("%5s %-40s", $algo->[0], decode_utf8($algo->[1])) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$nm" ) ;
	}
	# Devuelve una lista de listas con datos
	return @data;
}

sub modifica ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	my $bd = $esto->{'baseDatos'};
	
	$Mnsj = " ";
	if (not @datos) {
		$Mnsj = "NO hay datos para modificar";
		return;
	}
	
	$bNvo->configure(-state => 'disabled');
	$bReg->configure(-state => 'active');
	
	# Obtiene producto
	my @ns = $listaS->info('selection');
	my $prod = @datos[$ns[0]];
	
	# Rellena campos
	$Codigo =  $prod->[0];
	$Nombre = decode_utf8($prod->[1]);
	$Grupo = $prod->[2];
	$Unidad = $prod->[3];
	$GR = 'Grupo';
	foreach $algo ( @listaG ) {
		if ($algo->[0] eq $Grupo) { $GR = decode_utf8($algo->[1]); }
	}
	$UM = 'Unidad';
	foreach $algo ( @listaU ) {
		if ($algo->[0] eq $Unidad) { $UM = decode_utf8($algo->[1]); }
	}

	# Impide modificar codigo
	$codigo->configure(-state => 'disabled');
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
	if ($Grupo eq "") {
		$Mnsj = "Debe asignar un grupo.";
		$grupo->focus;
		return;
	}
	if ($Unidad eq "") {
		$Mnsj = "Debe registrar una unidad.";
		$um->focus;
		return;
	}
	# Graba datos
	$bd->grabaDatosP($Codigo,$Nombre,$Grupo,$Unidad);

	# Muestra lista actualizada de registros
	@datos = muestraLista($esto);

	limpiaCampos();	
	$codigo->configure(-state => 'normal');
	$bNvo->configure(-state => 'active');
	$bReg->configure(-state => 'disabled');
	$codigo->focus;
}

sub agrega ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	# Comprueba codigo
	$Mnsj = " ";
	if ($Codigo eq "") {
		$Mnsj = "Debe registrar un Código.";
		$codigo->focus;
		return;
	}
	# Verifica que se completen datos
	if ($Nombre eq "") {
		$Mnsj = "Debe registrar un nombre.";
		$nombre->focus;
		return;
	}
	if ($Grupo eq "") {
		$Mnsj = "Debe asignar un grupo.";
		$grupo->focus;
		return;
	}
	if ($Unidad eq "") {
		$Mnsj = "Debe registrar la unidad de medida.";
		$um->focus;
		return;
	}
	# Graba datos
	$bd->agregaP($Codigo,$Nombre,$Grupo,$Unidad);

	# Muestra lista modificada de registros
	@datos = muestraLista($esto);
	limpiaCampos();
	$codigo->focus;
}

sub limpiaCampos( )
{
	$codigo->delete(0,'end');
	$nombre->delete(0,'end');
#	$grupo->delete(0,'end');
#	$um->delete(0,'end');
	$Nombre = $Codigo = $Grupo = $Unidad = '';
}

sub eligeU {

	my ($jc, $Index) = @_;
	$Unidad = $listaU[$Index]->[0];
}

sub eligeG {

	my ($jc, $Index) = @_;
	$Grupo = $listaG[$Index]->[0];
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	
	$vn->destroy();
}

# Fin del paquete
1;
