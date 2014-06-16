#  BaseDatos.pm - Manejo de la base de datos en SQLite 3.2 o superior
#
#	Creado : 02/06/2014 
#	UM : 03/06/2014

package BaseDatos;

use strict;
use DBI;
#use Data::Dumper;

sub crea
{
  my ($esto, $nBD) = @_;
  
  $esto = {};
  $esto->{'baseDatos'} = DBI->connect( "dbi:SQLite:$nBD" ) || 
	die "NO se pudo conectar base de datos: $DBI::errstr";
  $esto->{'baseDatos'}->{'RaiseError'} = 1;

  bless $esto;
  return $esto;
}

sub cierra
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	
	$bd->disconnect();
}

# Lee, agrega y actualiza datos de Proveedores
sub datosT( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();
	
	my $sql = $bd->prepare("SELECT * FROM Proveedores ORDER BY Nombre");
	$sql->execute();
	
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();

	return @datos; 
}	

sub agregaT($ $ $ $ $)
{
	my ($esto, $Rut, $Nmbr, $Drccn, $Cmn, $Fch) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("INSERT INTO Proveedores VALUES(?,?,?,?,?);");
	$sql->execute($Rut, $Nmbr, $Drccn, $Cmn, $Fch);
	$sql->finish();
} 

sub grabaDatosT($ $ $ $)
{
	my ($esto, $Rut, $Nmbr, $Drccn, $Cmn) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("UPDATE Proveedores SET Nombre = ?, Direccion = ?,
		Comuna = ? WHERE Rut = ?;");
	$sql->execute($Nmbr, $Drccn, $Cmn, $Rut);
	$sql->finish();
} 

sub buscaT( )
{
	my ($esto, $rt) = @_;	
	my $bd = $esto->{'baseDatos'};
	
	my $sql = $bd->prepare("SELECT Nombre FROM Proveedores WHERE RUT = ?;");
	$sql->execute($rt);
	my $dato = $sql->fetchrow_array;
	$sql->finish();

	return $dato; 
}

# Lee, agrega y actualiza datos de Productos
sub datosP( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();
	
	my $sql = $bd->prepare("SELECT * FROM Productos ORDER BY Nombre");
	$sql->execute();
	
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();

	return @datos; 
}	

sub agregaP($ $ $ $)
{
	my ($esto, $Cdg, $Nmbr, $Grp, $Um) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("INSERT INTO Productos VALUES(?,?,?,?);");
	$sql->execute($Cdg, $Nmbr, $Grp, $Um);
	$sql->finish();
} 

sub grabaDatosP($ $ $)
{
	my ($esto, $Cdg, $Nmbr, $Grp, $UM) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("UPDATE Productos SET Nombre = ?, Grupo = ?,
		UM = ? WHERE Codigo = ?;");
	$sql->execute($Nmbr, $Grp, $UM, $Cdg);
	$sql->finish();
} 

sub buscaP( )
{
	my ($esto, $cdg) = @_;	
	my $bd = $esto->{'baseDatos'};
	
	my $sql = $bd->prepare("SELECT Nombre FROM Productos WHERE Codigo = ?;");
	$sql->execute($cdg);
	my $dato = $sql->fetchrow_array;
	$sql->finish();

	return $dato; 
}

# Lee, agrega y actualiza tabla Grupos y Umedida
sub datosGU( $ )
{
	my ($esto, $tbl) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();

	my $sql = $bd->prepare("SELECT * FROM $tbl ORDER BY Codigo;");
	$sql->execute();
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();
	
	return @datos; 
}	

sub idGU( $ $ )
{
	my ($esto, $Cdg, $tbl) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT ROWID FROM $tbl WHERE Codigo = ?;");
	$sql->execute($Cdg);
	my $dato = $sql->fetchrow_array;
	$sql->finish();
	
	return $dato; 
}

sub nombreGU( $ &)
{
	my ($esto, $Cdg, $tbl) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT Nombre FROM $tbl WHERE Codigo = ?;");
	$sql->execute($Cdg);
	my $dato = $sql->fetchrow_array;
	$sql->finish();
	
	return $dato; 
}

sub agregaGU( $ $ $ $ )
{
	my ($esto, $Cdg, $Nmbr, $Dscr, $tbl) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("INSERT INTO $tbl VALUES(?, ?, ?);");
	$sql->execute($Cdg, $Nmbr, $Dscr);
	$sql->finish();
} 

sub grabaGU( $ $ $ $ $ )
{
	my ($esto, $Cdg, $Nmbr, $Dscr, $Id, $tbl) = @_;	
	my $bd = $esto->{'baseDatos'};
	 
	my $sql = $bd->prepare("UPDATE $tbl SET Codigo = ?, Nombre = ?, 
		Descripcion = ? WHERE ROWID = ?;");
	$sql->execute($Cdg, $Nmbr, $Dscr, $Id);
	$sql->finish();
} 

# COMPROBANTES: Lee, agrega y actualiza tablas DatosC e ItemsC
sub creaTemp( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};

$bd->do("CREATE TEMPORARY TABLE ItemsT (
	Numero int(5),
	CuentaM char(5),
	Debe int(9),
	Haber int(9),
	Detalle char(15),
	RUT char(10),
	TipoD char(2),
	Documento char(10),
	CCosto char(3),
	Mes int(2),
	NombreC char(35) )" );
}

sub borraTemp( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};

	$bd->do("DROP Table ItemsT;");
}

sub datosItems( $ )
{
	my ($esto, $NmrC) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();

	my $sql = $bd->prepare("SELECT *,ROWID FROM ItemsT WHERE Numero = ?;");
	$sql->execute($NmrC);
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();
	
	return @datos; 
}	

sub itemsC( $ )
{
	my ($esto, $NmrC) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();

	my $sql = $bd->prepare("SELECT * FROM ItemsC WHERE Numero = ?;");
	$sql->execute($NmrC);
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();
	
	return @datos; 
}	

sub numeroC( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT max(Numero) FROM DatosC;");
	$sql->execute();
	my $dato = $sql->fetchrow_array;
	$sql->finish();
	$dato = 0 if not $dato ;	
	return $dato; 
}

sub sumas( $ )
{
	my ($esto, $Nmr) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT sum(Debe),sum(Haber) FROM ItemsT
		WHERE Numero = ?;");
	$sql->execute($Nmr);
	my @dato = $sql->fetchrow_array;
	$sql->finish();

	return ( $dato[0], $dato[1] ); 
}

sub totales( $ $ $)
{
	my ($esto, $cta, $mes, $op ) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT sum(Debe),sum(Haber) FROM ItemsC
		WHERE CuentaM = ? AND Mes $op ?;");
	$sql->execute($cta,$mes);
	my @dato = $sql->fetchrow_array;
	$sql->finish();

	return ( $dato[0], $dato[1] ); 
}

sub totalesF( $ $ $)
{
	my ($esto, $cta, $fi, $ff) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT sum(i.Debe),sum(i.Haber) FROM ItemsC AS i, DatosC AS d 
		WHERE i.CuentaM = ? AND i.Numero = d.Numero AND d.Fecha >= ? AND d.Fecha <= ?;");
	$sql->execute($cta,$fi,$ff);
	my @dato = $sql->fetchrow_array;
	$sql->finish();

	return ( $dato[0], $dato[1] ); 
}

sub agregaCmp( $ $ $ $ $ $ )
{
	my ($esto, $Numero, $Fecha, $Glosa, $Total, $Tipo, $bh) = @_;	
	my $bd = $esto->{'baseDatos'};
	my (@fila, $mes, $sql);

	# Graba datos basicos del Comprobante
	$sql = $bd->prepare("INSERT INTO DatosC VALUES(?, ?, ?, ?, ?, ?, ?);");
	$sql->execute($Numero, $Glosa, $Fecha, $Tipo, $Total, 0, 0);


}


# FACTURAS Ventas o Compras; NOTAS emitidas o recibidas

sub buscaFct( $ $ $ $ )
{
	my ($esto, $tbl, $rut, $doc, $campo) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT $campo FROM $tbl WHERE RUT = ? AND Numero = ?;");
	$sql->execute($rut, $doc);
	my $dato = $sql->fetchrow_array;
	$sql->finish();

	return $dato; 
}

sub buscaNI ()
{
	my ($esto, $tbl, $mes, $ni, $td) = @_;	
	my $bd = $esto->{'baseDatos'};
	
	my $sql = $bd->prepare("SELECT Rut,Numero,Comprobante,TF,FechaE,ROWID 
		FROM $tbl WHERE Orden = ? AND Tipo = ? AND Mes = ?;");
	$sql->execute($ni,$td,$mes);
	my @dato = $sql->fetchrow_array;
	$sql->finish();

	return @dato; 
	
}

sub listaFct( $ $ $ $)
{
	my ($esto, $tabla, $mes, $td, $tf) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();

	my $orden = 'Orden';
	$orden = 'Numero' if $tabla eq 'Ventas';
	my $sel = "SELECT FechaE, Numero, RUT, Total, IVA, Afecto, Exento, 
		Nulo, IEspec, Orden, Comprobante, IRetenido FROM $tabla WHERE Mes = ? AND Tipo = ?" ;
	$sel .= " AND TF = '$tf' " if $tf ;
	$sel .= " ORDER BY $orden " ; 
	my $sql = $bd->prepare($sel); 
	$sql->execute($mes,$td);
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();
	
	return @datos; 
}	

sub buscaDP ( $ $ $ ) 
{
	my ($esto,$Rut,$Num,$tbl) =  @_ ;
	my $bd = $esto->{'baseDatos'};
#	print "$Rut : $Num $tbl - ";
	my $sql = $bd->prepare("SELECT DocPago FROM Compras WHERE RUT = ? AND Numero = ?;");
	$sql->execute($Rut,$Num);
	
	my $dato = $sql->fetchrow_array;
	$sql->finish();
	
	if ($dato) {
		return $dato ;
	} else {
		return " ";
	}
}

sub datosFacts( $ $ )
{
	my ($esto, $Rut, $tbl, $impg) = @_;	
	my $bd = $esto->{'baseDatos'};
	my @datos = ();
	my $imp = ($tbl eq 'BoletasH') ? 'Retenido' : 'IVA';
	my $tp = ($tbl eq 'BoletasH') ? 'Cuenta' : 'Tipo';
	my $cns = "SELECT Numero,FechaE,Total,Abonos,FechaV,Comprobante,Nulo,$imp,$tp,Cuenta FROM $tbl WHERE RUT = ?" ;
	$cns .= " AND Pagada = 0 ORDER BY FechaE " if $impg ;
	my $sql = $bd->prepare($cns);
	$sql->execute($Rut);
	# crea una lista con referencias a las listas de registros
	while (my @fila = $sql->fetchrow_array) {
		push @datos, \@fila;
	}
	$sql->finish();
	
	return @datos; 
}	

# BOLETAS de CompraVenta
sub buscaBCV( $ )
{
	my ($esto, $fecha) = @_;	
	my $bd = $esto->{'baseDatos'};
	
	my $sql = $bd->prepare("SELECT Fecha FROM BoletasV WHERE Fecha = ?;");
	$sql->execute($fecha);
	my $dato = $sql->fetchrow_array;
	$sql->finish();

	return $dato; 
}

sub grabaBCV( $ $ $ $ )
{
	my ($esto, $fch, $de, $a, $mnt) = @_;	
	my $bd = $esto->{'baseDatos'};

	my @cmps = split /\//, $fch ;

	my $sql = $bd->prepare("INSERT INTO BoletasV VALUES(?,?,?,?,?,?,?);");
	$sql->execute($fch, $de, $a, $mnt, 0, '', $cmps[1]);
	$sql->finish();
	
}

# Termina el paquete
1;
