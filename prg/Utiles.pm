#  Utiles.pm - Paquete de funciones comunes varias
#  
#	Creado : 02/06/2014 
#   UM : 02/08/2014 

package Utiles;

use Encode 'decode_utf8';
use Date::Simple ('ymd','today','d8');
use Number::Format;

my $valida = 1 ;

sub crea
{
	my ($esto, $vp) = @_;
	
	$esto = {};
	$esto->{'Ventana'} = $vp;
	
	bless $esto;
	return $esto;
}

sub tipos ( )
{
	
	my ($t1, $t2 ,$t3, $tb, $tm, $tf, $fx,%tp);
	$tb = "bitstream-vera-sans";
	$tm = "bitstream-vera-sans-mono";
	$tf = "Courier 9";
	$fx = "monospace 10";
	($t1,$t2,$t3) = (11,10,10) ;
	if ($^O eq 'MSWin32') {
		$tb = "Arial";
		$tm = "Courier";
		$tf = $fx = "Courier 8";
	}
#	if ($^O eq 'darwin') {
#		$tb = "Arial" ;
#		$tf = $fx = "fixed";
#		($t1,$t2,$t3) = (12,11,10) ;
#	}
	%tp = ( 
		ng => "$tb $t1 bold" ,
		gr => "$tb $t2 bold" ,
		cn => "$tb $t3" ,
		tx => "$tm $t3" ,
		mn => "$tf" ,
		fx => "$fx") ;

	return %tp;	
}

sub ayuda 
{
	my ($esto, $mt, $ayd) = @_;

	$mt->delete('0.0','end');
	open AYD, "ayd/$ayd.txt" or die $!;
	my $i = 0;
	while ( <AYD> ) {
		if ($i == 0) { 
			$mt->insert('end', "$_", 'negrita' );
		} else { 
			if ($_ =~ s/^\.n//) {
				$mt->insert('end',"$_", 'grupo'); 
			} elsif ($_ =~ s/^\.s//) {
				$mt->insert('end',"$_", 'subt');
			} else  {
				$mt->insert('end',"$_",'cuenta' ); 
			}
		}
		$i += 1;
	} 
}

sub mError
{	
	my ($esto, $mensaje) = @_;
	
	my $vp = $esto->{'Ventana'};
	
	my $altoP = $vp->screenheight();
	my $anchoP = $vp->screenwidth();
	my $xpos = (($anchoP-400)/2);
	my $ypos = (($altoP-60)/2);
	my $vnt = $vp->Toplevel();
	$vnt->geometry("400x100+$xpos+$ypos");
	$vnt->resizable(0,0);
	$vnt->title("Mensaje de Advertencia");
	my $marco = $vnt->Frame(-borderwidth => 0);
	my $texto = $marco->Label(-text => "$mensaje\n",
		-justify => 'center');
	my $btn = $marco->Button(-text => 'Listo',-width => 5, 
		-command => sub {$vnt->destroy();} );
	
	$marco->pack(-side => 'right',-expand => 1);
	$texto->pack(-side => 'top');
	$btn->pack(-side => 'bottom');
		
	$vnt->waitWindow();	
}

sub vRut
{
	my ($esto, $rut) = @_;
	
	return 1 if not $valida ;
	
	for ($rut) {           # elimina espacios en blanco
        s/^\s+//;
        s/\s+$//;
    }

	my ($rt, $dvp, $lr,$j, $t, $dvc);
	
	$rt = $dvp = '';
	my @campos = split /-/, $rut;
	return 0 if not defined $campos[1]  ;
	
	my @digitos = (3, 2, 7, 6, 5, 4, 3, 2);
	$rt = $campos[0];
	$dvp = $campos[1]  ;
	$lr = length($rt) - 1;
	$j = @digitos;
	$t = 0;
	# Calcula dv
	until ($j-- == 0) {
	  last if $lr lt 0;
	  $t += substr($rt,$lr,1) * $digitos[$j];
	  $lr-- ; 
	}

	$dvc = 11 - ($t - int($t/11)*11);
	if ( $dvc == 10 ) { 
		$dvc = "K"; 
	} elsif ( $dvc == 11 ) { 
		$dvc = 0; 
	}
	my $res = ($dvc eq $dvp);
	
	return($res);
}

sub fechaHoy( )
{
	my @cmp = split /-/, today() ;
	
	return "$cmp[2]/$cmp[1]/$cmp[0]";
}

sub cFecha( $ )
{
	my ($esto, $ff) = @_;
#	my ($dm, $mes, $a);

	if (not $ff) { return "";}
	my @cmp = split /-/, $ff ;
	
	return "$cmp[2]/$cmp[1]/$cmp[0]";
#	$a = substr $ff,0,4;
#	$mes = substr $ff,5,2;
#	$dm = substr $ff,8,2;
#	return "$dm/$mes/$a";
}

sub analizaFecha ( $ ) 
{	
	my ($esto, $ff) = @_;
	# La fecha debe pasar en el formato "dd/mm/aaaa"
	my @cmp = split /\//, $ff ;
	# Devuelve una fecha v�lida (aaaa-mm-dd) o 'undef' en caso contrario
	$ff = ymd($cmp[2],$cmp[1],$cmp[0]) ;
	return $ff ;
}

sub diaAnterior ( $ )
{
	my ($esto, $ff) = @_;
	my $date = d8($ff);
	my @cmp = split /-/, $date - 1 ;
	return "$cmp[2]/$cmp[1]/$cmp[0]" ;
}

sub meses
{
	my @m = ( ['01','Enero'], ['02','Febrero'], ['03','Marzo'],
		['04','Abril'], ['05','Mayo'], ['06','Junio'], ['07','Julio'], 
		['08','Agosto'], ['09','Septiembre'], ['10','Octubre'], 
		['11','Noviembre'], ['12','Diciembre'] ) ;
	return @m ;
}

sub imprimirC ( $ $ $ ) # imprime comprobante
{
	my ($esto, $bd, $Numero, $Empresa) = @_;
	
	my $pesos = new Number::Format(-thousands_sep => '.', -decimal_point => ',');
	my $tc = {};
	$tc->{'I'} = 'Ingreso';
	$tc->{'E'} = 'Egreso';
	$tc->{'T'} = 'Traspaso';
	my ($nmrC, $tipoC, $fecha, $glosa, $total, $nulo, $a, $mes, $dm, $ff);
	
	my @datos = $bd->datosCmprb($Numero) ;
	$nmrC = $datos[0];
	$tipoC = $tc->{$datos[3]};
	$ff = $datos[2];
	$a = substr $ff,0,4;
	$mes = substr $ff,4,2;
	$dm = substr $ff,6,2;
	$fecha = "$dm/$mes/$a" ;
	$glosa = $datos[1];
	$total = $pesos->format_number( $datos[4] );
	$nulo = $datos[5];
	$ref = $datos[6];
	
	my $d = "var/cmprb.txt" ;
	open ARCHIVO, "> $d" or die $! ;

	my $lin = "\n$Empresa\n\nComprobante de $tipoC  # $nmrC              Fecha: $fecha\n" ;
	print ARCHIVO $lin ;
	print ARCHIVO "Glosa: $glosa\n\n";
	my @data = $bd->itemsC($nmrC);
	my ($algo, $ch, $cm, $ncta, $mntD, $mntH, $dt, $ci, $td, $dcm, $rtF, $nmb);
	my ($tD, $tH, $tch) = (0, 0, 0);
	$rtF = $nmb = $dcm = '' ;
	my $lin1 = "Cuenta                                       Debe        Haber"  . "\n";
	print ARCHIVO $lin1 ;
	my $lin2 = "-"x62;
	print ARCHIVO $lin2 . "\n" ;
	foreach $algo ( @data ) {
		$cm = $algo->[1];  
		$ncta = substr $bd->nmbCuenta($cm),0,30 ;
		$mntD = $mntH = $pesos->format_number(0);
		$mntD = $pesos->format_number( $algo->[2] ); 
		$tD += $algo->[2] ;
		$mntH = $pesos->format_number( $algo->[3] );
		$tH += $algo->[3] ;
		$ci = $algo->[6] ? substr $algo->[6], 0, 1 : '' ;
		$dcm = " " ;
		if ( $ci eq 'S' and $algo->[5] ) {
			$dcm = $bd->buscaT($algo->[5]) ;
			$dcm = $bd->buscaP($algo->[5]) if not $dcm ;
		} else {
			$dcm =  "$algo->[6] $algo->[7]" if $algo->[7] ;
			$dcm = $algo->[4] if $ci eq '' or $algo->[6] eq 'XZ';
		}
		$rtF = $algo->[5] if $ci eq 'F';
		if ($algo->[6] eq 'CH') {
			$ch = $algo->[7] ;
			$nBanco = $ncta;
			$tch += 1 ;
		}
		$dcm = substr $dcm,0,32 ;
		$lin = sprintf("%-5s %-30s %12s %12s  %-12s", $cm, $ncta, $mntD, $mntH, $dcm )  . "\n" ;
		print ARCHIVO $lin ;
	}
	print ARCHIVO $lin2 . "\n";
	$lin = sprintf("%36s %12s %12s", "Totales" ,
			$pesos->format_number($tD), $pesos->format_number($tH) ) . "\n";
	print ARCHIVO $lin ;
	print ARCHIVO $lin2 . "\n\n";
	
	$nmb = $bd->buscaT($rtF) ;
	print ARCHIVO "Pagado a: $nmb   RUT: $rtF\n" if $nmb;
	if ( $tch == 1 ) {
		print ARCHIVO "Cheque #: $ch   Banco: $nBanco \n" ;
	} else {
		print ARCHIVO "Cheques del Banco $nBanco\n" if $tch > 0 ;
	}
	
	print ARCHIVO "\n\n__________________     _______________    __________________   ______________" ;
	print ARCHIVO "\n    Emitido                 V� B�          Recibo Conforme           RUT" ;
	
	close ARCHIVO ;
	system "lp -o cpi=12 $d";
}

1;
