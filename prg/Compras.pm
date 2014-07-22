#  Compras.pm - Registra las compras de productos o servicios
#
#	Creado: 15/06/2014 
#	UM: 21/07/2014

package Compras;

use Tk::TList;
use Tk::LabEntry;
use Tk::LabFrame;
use Encode 'decode_utf8';
use Number::Format;

# Variables válidas dentro del archivo
# Datos a registrar
my ($Numero, $Id, $Fecha, $Neto, $Iva, $Total, $Nombre, $TipoF, $NmrI) ;
my ($Mnsj, $Codigo, $Monto, $RUT, $Dcmnt, $Cuenta, $Cantidad, $UM, $MU) ;
# Campos
my ($codigo, $detalle, $fecha, $neto, $iva, $um, $mu, $fe, $fm, $bc, $ot) ;
my ($total, $monto, $rut, $cantidad, $dcmnt, $numero, $cuenta, $nombre) ;
# Botones
my ($bReg, $bEle, $bNvo, $bCnt, $bCan) ; 
# Listas de datos	
my @datosP = () ;	# Datos de un producto
my @datos = () ;	# List de items comprados
# Formato de números
my $pesos = new Number::Format(-thousands_sep => '.', -decimal_point => ',');
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt ) = @_;

	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;
	$esto->{'ventana'} = $vp;
	$esto->{'marcoT'} = $mt;

	# Inicializa variables
	my %tp = $ut->tipos();
	$Numero = $bd->numeroC() + 1;
	$FechaC = $ut->fechaHoy();
	inicializaV();

	# Crea archivo temporal para registrar movimientos
	$bd->creaTemp();
	
	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
	my $alt = 450 ;
	$vnt->title("Registra Compras");
	$vnt->geometry("440x$alt+490+4");
		
	# Defime marcos
	my $mDatosC = $vnt->Frame(-borderwidth => 1);
	my $mDatosL2 = $vnt->Frame(-borderwidth => 1);
	my $mDatosN = $vnt->Frame(-borderwidth => 1);
	my $mDatosL3 = $vnt->Frame(-borderwidth => 1);
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Productos comprados");
	my $mItems = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Registra productos");
	my $mBotonesL = $vnt->Frame(-borderwidth => 1);
	my $mBotonesC = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes y botón de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'Compras'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');
	
	# Define Lista de datos
	my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe', -width => 60,
		-selectmode => 'single', -orient => 'horizontal', -font => $tp{mn},
		-command => sub { &modifica($esto) } );
	$esto->{'vLista'} = $listaS;
	
	# Define botones
	$bReg = $mBotonesL->Button(-text => "Modifica", 
		-command => sub { &registra($esto) } ); 
	$bEle = $mBotonesL->Button(-text => "Elimina", 
		-command => sub { &elimina($esto) } ); 
	$bNvo = $mBotonesL->Button(-text => "Agrega", 
		-command => sub { &agrega($esto) } ); 
	$bCnt = $mBotonesC->Button(-text => "Graba", 
		-command => sub { &graba($esto) } ); 
	$bCan = $mBotonesC->Button(-text => "Cancela", 
		-command => sub { &cancela($esto) } );

	# Campos para datos generales del documento
	$dcmnt = $mDatosC->LabEntry(-label => "Documento # ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Dcmnt);
	$fm = $mDatosC->Radiobutton( -text => "F.M.", -value => 'M', 
		-variable => \$TipoF );
	$fe = $mDatosC->Radiobutton( -text => "F.E.", -value => 'E', 
		-variable => \$TipoF );
	$bc = $mDatosC->Radiobutton( -text => "B", -value => 'B', 
		-variable => \$TipoF );
	$ot = $mDatosC->Radiobutton( -text => "O", -value => 'O', 
		-variable => \$TipoF );

	$rut = $mDatosL2->LabEntry(-label => "RUT: ", -width => 15,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'left', -textvariable => \$RUT);
	$fecha = $mDatosL2->LabEntry(-label => " Fecha:", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Fecha );
	$numero = $mDatosL2->LabEntry(-label => " Nº: ", -width => 4,
		-labelPack => [-side => "left", -anchor => "w"], #-bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Numero, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000');

	$nombre = $mDatosN->Label(	-textvariable => \$Nombre, -font => $tp{tx});

	$neto = $mDatosL3->LabEntry(-label => "Neto: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Neto);
	$iva = $mDatosL3->LabEntry(-label => " IVA: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Iva );
	$total = $mDatosL3->LabEntry(-label => " Total: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Total );

	# Campos para registro de productos
	$codigo = $mItems->LabEntry(-label => "Código: ", -width => 5,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Codigo );
	$cuenta = $mItems->Label(-textvariable => \$Cuenta, -font => $tp{tx});
	$monto = $mItems->LabEntry(-label => "Monto: ", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Monto); 
	$cantidad= $mItems->LabEntry(-label => " Cantidad: ", -width => 6,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Cantidad); 
	$um = $mItems->Label(-textvariable => \$UM, -font => $tp{tx});
	$mu = $mItems->LabEntry(-label => " V. Unitario ", -width => 8,
		-labelPack => [-side => "left", -anchor => "w"],
		-textvariable => \$MU, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000'); 
			
	# Habilita validación de datos
	$fecha->bind("<FocusIn>", sub { &buscaDoc($esto) } );
	$neto->bind("<FocusOut>", sub { &totaliza() } );
#	$iva->bind("<FocusIn>", sub { $Iva = int( $Neto * $pIVA / 100 + 0.5) ;} );
	$iva->bind("<FocusOut>", sub { &totaliza() } );	
	$codigo->bind("<FocusIn>", sub { &datosF($esto) } );
	$monto->bind("<FocusIn>", sub { &buscaP($bd,\$Codigo,\$Cuenta,\$codigo,\$UM ) } );
	$cantidad->bind("<FocusOut>", sub { &vUnitario() } );

	@datos = muestraLista($esto);
	if (not @datos) {
		$listaS->insert('end', -itemtype => 'text', 
			-text => "No hay movimientos registrados" ) ;
	}
	
	# Dibuja interfaz	
	$dcmnt->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fm->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fe->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bc->pack(-side => 'left', -expand => 0, -fill => 'none');
	$ot->pack(-side => 'left', -expand => 0, -fill => 'none');

	$rut->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fecha->pack(-side => 'left', -expand => 0, -fill => 'none');
	$numero->pack(-side => 'left', -expand => 0, -fill => 'none');

	$nombre->pack(-side => 'left', -expand => 0, -fill => 'none');

	$neto->pack(-side => 'left', -expand => 0, -fill => 'none');
	$iva->pack(-side => 'left', -expand => 0, -fill => 'none');
	$total->pack(-side => 'left', -expand => 0, -fill => 'none'); 
	
	$codigo->grid(-row => 0, -column => 0, -sticky => 'nw');	
	$cuenta->grid(-row => 0, -column => 1, -columnspan => 3, -sticky => 'nw');
	$monto->grid(-row => 1, -column => 0, -sticky => 'nw');	
	$cantidad->grid(-row => 1, -column => 1, -sticky => 'nw');
	$um->grid(-row => 1, -column => 2, -sticky => 'nw');
	$mu->grid(-row => 1, -column => 3, -sticky => 'nw');
	
	$bReg->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bEle->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bNvo->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCnt->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'right', -expand => 0, -fill => 'none');

	$listaS->pack();
	$mDatosC->pack(-expand => 1);
	$mDatosL2->pack(-expand => 1);
	$mDatosN->pack(-expand => 1);
	$mDatosL3->pack(-expand => 1);
	$mBotonesC->pack(-expand => 1);
	$mLista->pack(-expand => 1);
	$mItems->pack(-expand => 1);
	$mBotonesL->pack(-expand => 1);
	$mMensajes->pack(-expand => 1, -fill => 'both');

	# Inicialmente deshabilita algunos botones
	$bReg->configure(-state => 'disabled');
	$bEle->configure(-state => 'disabled');
	$bCnt->configure(-state => 'disabled');
	
	$dcmnt->focus;

	bless $esto;
	return $esto;
}

# Funciones internas
sub totaliza ( ) 
{
	$Total = $Neto + $Iva ;
}

sub vUnitario ( ) 
{
	$MU = sprintf("%.0f", $Monto / $Cantidad) ; # redondea el resultado
}

sub validaFecha ($ $ $ $ ) 
{
	my ($ut, $v, $c, $x) = @_;
	
	$Mnsj = " ";
	if ( not $$v ) {	
		if ($x == 0) { return ; }
		$Mnsj = "Debe colocar fecha de emisión";
		$$c->focus;
		return ;
	} 
	if ( not $$v =~ m|\d+/\d+/\d+| ) {
		$Mnsj = "Problema con formato. Debe ser dd/mm/aaa";
		$$c->focus;
	} elsif ( not $ut->analizaFecha($$v) ) {
		print chr 7 ;
		$Mnsj = "Fecha incorrecta";
		$$c->focus;
	}
}

sub buscaP ( $ $ $ $ ) 
{
	my ($bd, $a, $b, $c, $d ) = @_;

	# Comprueba largo del código de la cuenta
	if (length $$a < 4) {
		$Mnsj = "Código debe tener 4 dígitos";
		$$c->focus;
		return ;
	}
	# Busca producto
	@datosP = $bd->dtProducto($$a);
	if ( not @datosP ) {
		$Mnsj = "Ese código NO está registrado";
		$$c->focus;
	} else {
		$$b = substr decode_utf8(" $datosP[0]"),0,35;
		$$d = $datosP[1] ;
		$Mnsj = " ";
	}
}


sub buscaDoc ( $ )
{ 
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $ut = $esto->{'mensajes'};

	if ($Dcmnt eq '') {
		$Mnsj = "Registre número de Factura";
		$dcmnt->focus;
		return ;
	}
	# Valida que sea número entero
	if (not $Dcmnt =~ /^(\d+)$/) {
		$Mnsj = "NO es un número válido.";
		$dcmnt->focus;
		return ;
	}
	# Busca RUT
	if (not $RUT) {
		$Mnsj = "Debe registrar un RUT.";
		$rut->focus;
		return ;
	}
	$RUT = uc($RUT);
	if ( not $ut->vRut($RUT) ) {
		$Mnsj = "El RUT no es válido";
		$rut->focus;
		return ;
	} else {
		my $nmb = $bd->buscaT($RUT);
		if (not $nmb) {
			$Mnsj = "Ese RUT no aparece registrado.";
			$rut->focus;
			return ;
		} 
		$Nombre = decode_utf8(" $nmb");
	}
	# Verifica que la factura NO esté registrada
	my $fct = $bd->buscaDC($RUT, $Dcmnt);
	if ($fct) {
		$Mnsj = "Esa Factura ya está registrada.";
		$dcmnt->focus;
		return ;
	}
}

sub datosF ( $ ) # Comprueba los datos mínimos para anotar un item
{ 
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $ut = $esto->{'mensajes'}; 
	
	if (not $RUT) {
		$Mnsj = "Indique RUT.";
		$rut->focus ;
		return ;
	}
	if (not $Dcmnt) {
		$Mnsj = "Primero registre número de factura.";
		$dcmnt->focus ;
		return ;
	}
	# agregar más comprobaciones
}

sub muestraLista ( $ ) 
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos de ítemes registrados
	my @data = $bd->datosItems($Numero);

	# Completa TList con código, nombre producto, monto y cantidad 
	my ($algo, $mov, $cm, $mnt, $cntd, $np, $u);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$cm = $algo->[1];  # Código producto
		$mnt = $pesos->format_number( $algo->[4] ); 
		$cntd = $algo->[2] ;
		$u = $algo->[3] ;
		$np = substr decode_utf8($algo->[6]),0,30 ;
		$mov = sprintf("%-4s %-30s %8s %3s %10s", 
			$cm, $np, $cntd, $u, $mnt ) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$mov" ) ;
	}
	# Devuelve una lista de listas con datos de los productos
	return @data;
}

sub agrega ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	$Mnsj = " ";
	# Verifica que se completen datos de detalle
	if (not $Codigo) {
		$Mnsj = "Registre el código del producto.";
		return;
	}
	if (length $Codigo < 4) {
		$Mnsj = "Código debe tener 4 dígitos.";
		$codigo->focus;
		return;
	}
	if ($Monto == 0) {
		$Mnsj = "Anote alguna cifra.";
		$monto->focus;
		return;
	}
	if ($Cantidad == 0) {
		$Mnsj = "Indique la cantidad.";
		$cantidad->focus;
		return;
	}
	# Graba datos
	$bd->agregaItemT($Numero,$Codigo,$Cantidad,$UM,$Monto,$MU,$Cuenta);

	# Muestra lista modificada de productos
	@datos = muestraLista($esto);

	# Totaliza itemes
	$TotalI += $Monto ;
	if ($TotalI == $Neto) {	
		$bCnt->configure(-state => 'disabled');
	}
	limpiaCampos();
	$codigo->focus;
}

sub modifica ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	my $bd = $esto->{'baseDatos'};
		
	$Mnsj = " ";
	if (not @datos) {
		$Mnsj = "NO hay movimientos para modificar";
		return;
	}
	
	$bNvo->configure(-state => 'disabled');
	$bReg->configure(-state => 'active');
	$bEle->configure(-state => 'active');
	
	# Obtiene item seleccionado
	my @ns = $listaS->info('selection');
	my $sItem = @datos[$ns[0]];
	
	# Rellena campos
	$Codigo = $sItem->[1];
	$Monto = $sItem->[2] ? $sItem->[2] : $sItem->[3] ;
	$Detalle = decode_utf8($sItem->[4]);
	$Cuenta = $sItem->[10];	
	$CCto = $sItem->[8];

	# Obtiene Id del registro
	$Id = $sItem->[11];
}

sub registra ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'} ;
	# Graba datos
	$bd->grabaItemT($Codigo, $Detalle, $Monto, $DH, '', $TipoD, $Dcmnt, 
	 $Cuenta, $Id);

	# Muestra lista actualizada de items
	@datos = muestraLista($esto);
	
	# Retotaliza comprobante
	my ($td, $th) = $bd->sumas($Numero);
	$TotalI = ($DH eq "D") ? $td : $th ;
	if ($TotalI == $Neto) {	
		$bCnt->configure(-state => 'active');
	}
	limpiaCampos();
	
	$bNvo->configure(-state => 'active');
	$bEle->configure(-state => 'disabled');
	$bReg->configure(-state => 'disabled');
}

sub elimina ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'} ;
	# Graba
	$bd->borraItemT( $Id );
	
	# Muestra lista actualizada de items
	@datos = muestraLista($esto);

	$TotalI -= $Monto;
	limpiaCampos();

	$bNvo->configure(-state => 'active');
	$bEle->configure(-state => 'disabled');
	$bReg->configure(-state => 'disabled');
}

sub graba ( )
{
	my ($esto) = @_;
	my $ut = $esto->{'mensajes'};
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Verifica que se completen datos básicos
	if ($TipoF eq '' ) {
		$Mnsj = "Debe marcar tipo documento.";
		$fm->focus;
		return;				
	}
	if ($Fecha eq '' ) {
		$Mnsj = "Anote la fecha del documento.";
		$fecha->focus;
		return;
	}
	$Mnsj = " ";

	# Graba documento
	my $fc = $ut->analizaFecha($FechaC); 
	$bd->agregaCmp($Numero,$RUT,$fc,$TipoF,$Dcmnt,$Total,$Neto,$Iva);

	limpiaCampos();
	$bCnt->configure(-state => 'disabled');
	$listaS->delete(0,'end');
	$listaS->insert('end', -itemtype => 'text', 
			-text => "No hay movimientos registrados" ) ;
	# Inicializa variables
	inicializaV();
	$Numero = $bd->numeroC() + 1;
	$Dcmnt = '' ; 
	$dcmnt->focus;
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	my $bd = $esto->{'baseDatos'};
	
	$bd->borraTemp();
	$vn->destroy();
}

sub limpiaCampos ( )
{
	$codigo->delete(0,'end');
	$Monto = $Cantidad = $MU = 0;
	$Cuenta = '                    ';
	
	# Activa o desactive el botón para grabar el documento
	if ($Neto == $TotalI) {
		$bCnt->configure(-state => 'active');
	} else {
		$bCnt->configure(-state => 'disabled');
	}
}

sub inicializaV ( )
{
	$Monto = $TotalI = $Total = $Neto = $Iva = $Cantidad = $MU = 0;
	$Dcmnt = $Codigo = $RUT = $Fecha = $TipoF = '';
	$Cuenta = $Nombre = '                    ';
	$UM = '   ';

}

# Fin del paquete
1;
