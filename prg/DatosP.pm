#  DatosP.pm - Registra o modifica Productos
#  
# 	Creado : 03/06/2014 
#	UM : 03/06/2014

package DatosP;

use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';
	
# Variables v�lidas dentro del archivo
my ($Nombre, $Codigo, $Grupo, $Unidad, $Mnsj,@listaU,@listaG,$GR,$UM);
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
	$vnt->geometry("360x350+490+4"); # Tama�o y ubicaci�n
	
	# Defime marcos
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Productos registrados");
	my $mDatos = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Datos Producto");
	my $mBotones = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	
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
	$codigo = $mDatos->LabEntry(-label => "C�digo:   ", -width => 5,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Codigo );
	$nombre = $mDatos->LabEntry(-label => "Nombre:  ", -width => 35,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Nombre);
	$nombre->bind("<FocusIn>", sub { &buscaCod($esto) } );
#	$grupo = $mDatos->LabEntry(-label => "Grupo:     ", -width => 4,
#		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
#		-textvariable => \$Grupo);
#	$um = $mDatos->LabEntry(-label => "UM: ", -width => 3,
#		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
#		-textvariable => \$Unidad );
	my $grT = $mDatos->Label(-text => "Grupo ");
	$grupo = $mDatos->BrowseEntry( -variable => \$GR, -state => 'readonly',
		-disabledbackground => '#FFFFFC', -autolimitheight => 1,
		-disabledforeground => '#000000', -autolistwidth => 1,
		-browse2cmd => \&eligeG );
	@listaG = $bd->datosGU('Grupos');
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
	$grupo->grid(-row => 2, -column => 0, -columnspan => 6, -sticky => 'nw');
	$umT->grid(-row => 2, -column => 3, -columnspan => 6, -sticky => 'nw');
	$um->grid(-row => 2, -column => 3, -columnspan => 6, -sticky => 'nw');

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
	$codigo->focus;
	
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
		$Mnsj = "Debe registrar un c�digo.";
		$codigo->focus;
		return;
	}
	
	my $nmb = $bd->buscaP($Codigo);
	if ( $nmb) {
		$Mnsj = "Ese c�digo ya est� registrado.";
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
		$Mnsj = "Debe registrar un nombre.";
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
		$Mnsj = "Debe registrar un C�digo.";
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
		$Mnsj = "Debe registrar un nombre.";
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
	$grupo->delete(0,'end');
	$Nombre = $Codigo = $Grupo = $Unidad = '';
}

sub eligeU {

	my ($jc, $Index) = @_;
	$Unidad = $listaU[$Index]->[0];
}

sub eligeG {

	my ($jc, $Index) = @_;
	$Grupo = $listaG[$Index]->[0];
	$Mnsj = $Grupo ;
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	
	$vn->destroy();
}

# Fin del paquete
1;
