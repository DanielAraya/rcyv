#  BaseDatos.pm - Manejo de la base de datos en SQLite 3.2 o superior
#
#	Creado : 02/06/2014 
#	UM : 04/07/2014

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

sub dtProducto( $ )
{
	my ($esto, $Cdg) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT Nombre,UM,Grupo FROM producto 
		WHERE Codigo = ?;");
	$sql->execute($Cdg);
	my @dato = $sql->fetchrow_array;
	$sql->finish();
	
	return @dato; 
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

# COMPRAS: Lee, agrega y actualiza tablas DatosC e ItemsC
sub creaTemp( )
{
	my ($esto) = @_;	
	my $bd = $esto->{'baseDatos'};

$bd->do("CREATE TEMPORARY TABLE ItemsT (
	Numero int(5),
	CodigoP char(4),
	Cantidad int(4),
	UnidadM char(2),
	ValorT int(7),
	ValorU int(5),
	NombreP char(35) )" );
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

sub borraItemT( $ )
{
	my ($esto, $Id) = @_;	
	my $bd = $esto->{'baseDatos'};

	$bd->do("DELETE FROM ItemsT WHERE ROWID = $Id ;");
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

	my $sql = $bd->prepare("SELECT max(Numero) FROM Compras;");
	$sql->execute();
	my $dato = $sql->fetchrow_array;
	$sql->finish();
	$dato = 0 if not $dato ;	
	return $dato; 
}

sub agregaCmp( $ $ $ $ $ $ $ $)
{
	my ($esto,$Numero,$RUT,$Fecha,$TipoF,$Dcmnt,$Total,$Neto,$Iva) = @_;	
	my $bd = $esto->{'baseDatos'};
	my $sql ;

	# Graba datos basicos del Comprobante
	$sql = $bd->prepare("INSERT INTO DatosC VALUES(?,?,?,?,?,?,?,?);");
	$sql->execute($Numero,$RUT,$Fecha,$TipoF,$Dcmnt,$Total,$Neto,$Iva);
	# Graba items desde el archivo temporal
	$bd->do("INSERT INTO ItemsC SELECT Numero,CodigoP,Cantidad,UMedida,
		ValorT,ValorU FROM ItemsT WHERE Numero = $Numero ;") ;
	# Borra datos temporales
	$bd->do("DELETE FROM ItemsT");

}

sub agregaItemT( $ $ $ $ $ $ $ )
{
	my ($esto,$Numero,$Codigo,$Cantidad,$UM,$Monto,$MU,$Cuenta) = @_;	
	my $bd = $esto->{'baseDatos'};
	my $sql;

	$sql = $bd->prepare("INSERT INTO ItemsT VALUES(?,?,?,?,?,?,?);");
	$sql->execute($Numero, $Codigo, $Cantidad, $UM, $Monto, $MU, $Cuenta );
	$sql->finish();

} 

# FACTURAS Ventas o Compras
sub buscaDC( $ $ $ $ )
{
	my ($esto, $rut, $doc) = @_;	
	my $bd = $esto->{'baseDatos'};

	my $sql = $bd->prepare("SELECT Numero FROM Compras WHERE RUT = ? AND Factura = ?;");
	$sql->execute($rut, $doc);
	my $dato = $sql->fetchrow_array;
	$sql->finish();

	return $dato; 
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

# Termina el paquete
1;
