UNIT comandos;
INTERFACE

Uses BaseUnix, Unix, crt, utilidades;

procedure cat	(var dir1,dir2: string; tipo: byte);			// CAT - Concatena hasta dos archivos, o un archivo con la salida estandar
procedure exec 	(param1: String; param2: Array of AnsiString);	// EXEC - Ejecuta un programa externo. Ruta relativa o absoluta.
procedure kill 	(signal, proc: longint);						// KILL - Envía una señal a un proceso.
procedure ls	(tipo: byte); 									// LS - Lista los archivos de un determinado directorio.
procedure lsA	(tipo: byte); 									// variante de LS, lista archivos ocultos.
procedure lsF	(tipo: byte); 									// variante de LS, lista sin ordenar ni aplicar colores.
procedure lsL	(tipo: byte);  									// variante de LS, lista archivos en formato largo.
procedure lsLA	(tipo: byte); 									// LS -l -a
procedure lsLF	(tipo: byte); 									// LS -l -f
procedure lsAF	(tipo: byte); 									// LF -a -f
procedure lsAFL	(tipo: byte); 									// LF -a -f -l
procedure pwd	(tipo: byte); 									// PWD - Muestra el directorio actual de trabajo.
procedure prueba;                                                                               // Prueba mostrara en pantalla un ciclo de letras simil a 'yes'

IMPLEMENTATION


//Comando CAT
procedure cat(var dir1,dir2: string; tipo: byte);
var f1,f2: text;
	texto: string;
	err: boolean;

Begin
	err:= false;
	{$I-}		// Evita generar código de control de entrada/salida en el programa
	assign(f1,dir1);
	reset(f1);
	if IOResult <> 0 then err := true else
	begin
		while not eof(f1) do
		begin
			readln(f1,texto);
			if tipo = 0 then writeln(texto) else writeln(stdOutPut,texto);
		end;
		close(f1);
	end;
	if dir2 <> '' then
	begin
		assign(f2,dir2);
		reset(f2);
		if IOResult <> 0 then err := true else
		begin
		while not eof(f2) do
			begin
				readln(f2,texto);
				if tipo = 0 then writeln(texto) else writeln(stdOutPut,texto);
			end;
			close(f2);
		end;
	end;
	if err then error(10);
	{$I+}		// Habilita la generación de código de entrada/salida
End;


//Comando CD
{
	El comando CD es ejecutado directamente
	por el analizadorCD en la UNIT analizador

}


//Comando EXEC
procedure exec (param1: String; param2: Array of AnsiString);
var pid,op: longint;

Begin
	op:= 0;
	pid:= -1;
		case fpFork of
		-1: error(3);
		0: 	Begin
				fpExecLP(param1,param2);
			End;
		else
			begin
			fpWaitPid(pid,op,op); //Espera por cualquier proceso hijo.
			end;
		end;
End;


//Comando KILL
procedure kill (signal, proc: longint);
Begin
	fpKill(proc,signal);
End;


//Comando LS
procedure ls(tipo: byte);
{
	Los archivos marcados como inaccesibles son aquellos
	en los cuales fpStat devuelve un error. En dicho caso se puede saber
	el nombre del archivo, pero no datos referidos al tipo de archivo.

}

var	directorio: pdir;
	entrada: PDirent;
	vector: vDirent;
	indice,j: integer;
	K: byte;
	info: stat;

Begin
	k:= 1;
	indice:= 0;
	directorio := fpOpenDir(dirActual);
	if directorio <> nil  then
	begin	//openDir
	repeat
		entrada:= fpReadDir(directorio^);
		if (entrada <> nil) and (entrada^.d_name[0] <> '.') then
		begin
			inc(indice);
			vector[indice]:= entrada^;
		end;
	until entrada = nil;
	burbujaDirent(vector,indice);
	for J:= 1 to indice do
	Begin //for
		if fpStat(pchar(vector[J].d_name),info)=0 then
		Begin  //fpStat
			if fpS_ISLNK(info.st_mode) then textattr:= $0B;
			if fpS_ISDIR(info.st_mode) then textattr:= $09;
			if fpS_ISREG(info.st_mode) then
				if puntos(strPas(vector[J].d_name)) < 1 then textattr:= $0A
					else textattr:= $07;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25))
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25):20)
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25):20);
				end;
			end; // case
			if k = 3 then k:= 1 else inc(K);
		End // fpStat
		else
		Begin // else fpStat
			textAttr:= $04;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12))
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20)
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20);
				end;
			end; //case
			if k = 3 then k:= 1 else inc(K);
		end; // else fpStat
	End; // for
	fpCloseDir(directorio^);
	end  // OpenDir
	else error(4);
End;



//comando LS -a
procedure lsA(tipo: byte);
{
	Los archivos marcados como inaccesibles son aquellos
	en los cuales fpStat devuelve un error. En dicho caso se puede saber
	el nombre del archivo, pero no datos referidos al tipo de archivo.

}

var	directorio: pdir;
	entrada: PDirent;
	vector: vDirent;
	indice,j: integer;
	K: byte;
	info: stat;

Begin
	k:= 1;
	indice:= 0;
	directorio := fpOpenDir(dirActual);
	if directorio <> nil  then
	begin	//openDir
	repeat
		entrada:= fpReadDir(directorio^);
		if (entrada <> nil) then
		begin
			inc(indice);
			vector[indice]:= entrada^;
		end;
	until entrada = nil;
	burbujaDirent(vector,indice);
	for J:= 1 to indice do
	Begin //for
		if fpStat(pchar(vector[J].d_name),info)=0 then
		Begin  //fpStat
			if fpS_ISLNK(info.st_mode) then textattr:= $0B;
			if fpS_ISDIR(info.st_mode) then textattr:= $09;
			if fpS_ISREG(info.st_mode) then
				begin
				if (puntos(strPas(vector[J].d_name)) = 1) and (strPas(vector[J].d_name)[1] = '.') then textattr:= $0A
					else textattr:= $07;
				if (puntos(strPas(vector[J].d_name)) = 0) then textattr:= $0A
					else textattr:= $07;
				end;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25))
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25):20)
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25):20);
				end;
			end; // case
			if k = 3 then k:= 1 else inc(K);
		End // fpStat
		else
		Begin // else fpStat
			textAttr:= $04;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12))
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20)
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20);
				end;
			end; //case
			if k = 3 then k:= 1 else inc(K);
		end; // else fpStat
	End; // for
	fpCloseDir(directorio^);
	end  // OpenDir
	else error(4);
End;


//comando LS -f
procedure lsF(tipo: byte);
{
	Los archivos marcados como inaccesibles son aquellos
	en los cuales fpStat devuelve un error. En dicho caso se puede saber
	el nombre del archivo, pero no datos referidos al tipo de archivo.

}

var	directorio: pdir;
	entrada: PDirent;
	vector: vDirent;
	indice,j: integer;
	K: byte;
	info: stat;

Begin
	k:= 1;
	indice:= 0;
	directorio := fpOpenDir(dirActual);
	if directorio <> nil  then
	begin	//openDir
	repeat
		entrada:= fpReadDir(directorio^);
		if (entrada <> nil) and (entrada^.d_name[0] <> '.') then
		begin
			inc(indice);
			vector[indice]:= entrada^;
		end;
	until entrada = nil;
	for J:= 1 to indice do
	Begin //for
		if fpStat(pchar(vector[J].d_name),info)=0 then
		Begin  //fpStat
			textAttr:= $07;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25))
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25):20)
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25):20);
				end;
			end; // case
			if k = 3 then k:= 1 else inc(K);
		End // fpStat
		else
		Begin // else fpStat
			textAttr:= $04;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12))
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20)
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20);
				end;
			end; //case
			if k = 3 then k:= 1 else inc(K);
		end; // else fpStat
	End; // for
	fpCloseDir(directorio^);
	end  // OpenDir
	else error(4);
End;



//comando LS -l
procedure lsL(tipo: byte);
{
	En caso de falla obteniendo los datos de un archivo se mostrará
	el mensaje "No se pudo mostrar.", que representa una falla en fpStat.

}

var	directorio	: Pdir;
	entrada		: PDirent;
	info		: stat;
	vector		: vDirent;
	contArchivos: integer;
	indice,j	: integer;

Begin
	indice:= 0;
	contArchivos:= 0; 	//número de archivos listados
	directorio:= fpOpenDir(dirActual);
	if directorio <> nil then
	begin //openDir
		repeat
			entrada:= fpReadDir(directorio^);
			if (entrada <> nil) and (entrada^.d_name[0] <> '.') then
			Begin	//if readDir
				inc(indice);
				vector[indice]:= entrada^;
			end;	//if readDir
		until entrada = nil;
		burbujaDirent(vector, indice);
		for J:= 1 to indice do
			begin //for
			if fpStat(pchar(vector[J].d_name),info)=0 then
				Begin //fpStat
				textattr:= $07;
				contArchivos:= contArchivos + 1;
					if tipo = 0 then write('Permisos: ') else write(stdOutPut,'Permisos: ');
					if (fpAccess (pchar(vector[J].d_name),R_OK)=0) then if tipo = 0 then write('r ') else write(stdOutPut,'r ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),W_OK)=0) then if tipo = 0 then write('w ') else write(stdOutPut,'w ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),X_OK)=0) then if tipo = 0 then write('x ') else write(stdOutPut,'x ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if tipo = 0 then write(' ',info.st_size,' bytes. ') else write(stdOutPut,' ',info.st_size,' bytes. ');
					gotoxy(35,wherey);
					if fpS_ISLNK(info.st_mode) then textattr:= $0B;
					if fpS_ISDIR(info.st_mode) then textattr:= $09;
					if fpS_ISREG(info.st_mode) then
						if puntos(strPas(vector[J].d_name)) < 1 then textattr:= $0A
							else textattr:= $07;
					if tipo = 0 then writeln(pchar(vector[J].d_name)) else writeln(stdOutPut,pchar(vector[J].d_name));
				End // fpStat
				else if tipo = 0 then writeln('No se pudo mostrar.') else writeln(stdOutPut,'No se pudo mostrar.');
			end; //for
		textattr:= $07;
		if tipo = 0 then writeln('- - - - - - - - - - - - - - - -') else writeln(stdOutPut,'- - - - - - - - - - - - - - - -');
		if contArchivos = 0 then if tipo=0 then writeln('No hay listado.') else writeln(stdOutPut,'No hay listado.') else
		if tipo = 0 then writeln('Nro. de archivos listados: ',contArchivos) else writeln(stdOutPut, 'Nro. de archivos listados',contArchivos);
		fpCloseDir(directorio^);
	end //openDir
	else error(4);
End;


// Procedure LS -l -a
procedure lsLA(tipo: byte);
{
	En caso de falla obteniendo los datos de un archivo se mostrará
	el mensaje "No se pudo mostrar.", que representa una falla en fpStat.

}

var	directorio	: Pdir;
	entrada		: PDirent;
	info		: stat;
	vector		: vDirent;
	contArchivos: integer;
	indice,j	: integer;

Begin
	indice:= 0;
	contArchivos:= 0; 	//número de archivos listados
	directorio:= fpOpenDir(dirActual);
	if directorio <> nil then
	begin //openDir
		repeat
			entrada:= fpReadDir(directorio^);
			if (entrada <> nil) then
			Begin	//if readDir
				inc(indice);
				vector[indice]:= entrada^;
			end;	//if readDir
		until entrada = nil;
		burbujaDirent(vector, indice);
		for J:= 1 to indice do
			begin //for
			if fpStat(pchar(vector[J].d_name),info)=0 then
				Begin //fpStat
				textattr:= $07;
				contArchivos:= contArchivos + 1;
					if tipo = 0 then write('Permisos: ') else write(stdOutPut,'Permisos: ');
					if (fpAccess (pchar(vector[J].d_name),R_OK)=0) then if tipo = 0 then write('r ') else write(stdOutPut,'r ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),W_OK)=0) then if tipo = 0 then write('w ') else write(stdOutPut,'w ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),X_OK)=0) then if tipo = 0 then write('x ') else write(stdOutPut,'x ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if tipo = 0 then write(' ',info.st_size,' bytes. ') else write(stdOutPut,' ',info.st_size,' bytes. ');
					gotoxy(35,wherey);
					if fpS_ISLNK(info.st_mode) then textattr:= $0B;
					if fpS_ISDIR(info.st_mode) then textattr:= $09;
					if fpS_ISREG(info.st_mode) then
						begin
						if (puntos(strPas(vector[J].d_name)) <= 1) and (strPas(vector[J].d_name)[1] = '.') then textattr:= $0A
						else textattr:= $07;
						if (puntos(strPas(vector[J].d_name)) < 1) and (strPas(vector[J].d_name)[1] <> '.') then textattr:= $0A
						else textattr:= $07;
						end;
					if tipo = 0 then writeln(pchar(vector[J].d_name)) else writeln(stdOutPut,pchar(vector[J].d_name));
				End // fpStat
				else if tipo = 0 then writeln('No se pudo mostrar.') else writeln(stdOutPut,'No se pudo mostrar.');
			end; //for
		textattr:= $07;
		if tipo = 0 then writeln('- - - - - - - - - - - - - - - -') else writeln(stdOutPut,'- - - - - - - - - - - - - - - -');
		if contArchivos = 0 then if tipo=0 then writeln('No hay listado.') else writeln(stdOutPut,'No hay listado.') else
		if tipo = 0 then writeln('Nro. de archivos listados: ',contArchivos) else writeln(stdOutPut, 'Nro. de archivos listados',contArchivos);
		fpCloseDir(directorio^);
	end //openDir
	else error(4);
End;


// Procedure LS -l -f
procedure lsLF(tipo: byte);
{
	En caso de falla obteniendo los datos de un archivo se mostrará
	el mensaje "No se pudo mostrar.", que representa una falla en fpStat.

}

var	directorio	: Pdir;
	entrada		: PDirent;
	info		: stat;
	vector		: vDirent;
	contArchivos: integer;
	indice,j	: integer;

Begin
	indice:= 0;
	contArchivos:= 0; 	//número de archivos listados
	directorio:= fpOpenDir(dirActual);
	textattr:= $07;
	if directorio <> nil then
	begin //openDir
		repeat
			entrada:= fpReadDir(directorio^);
			if (entrada <> nil) and (entrada^.d_name[0] <> '.') then
			Begin	//if readDir
				inc(indice);
				vector[indice]:= entrada^;
			end;	//if readDir
		until entrada = nil;
		for J:= 1 to indice do
			begin //for
			if fpStat(pchar(vector[J].d_name),info)=0 then
				Begin //fpStat
				contArchivos:= contArchivos + 1;
					if tipo = 0 then write('Permisos: ') else write(stdOutPut,'Permisos: ');
					if (fpAccess (pchar(vector[J].d_name),R_OK)=0) then if tipo = 0 then write('r ') else write(stdOutPut,'r ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),W_OK)=0) then if tipo = 0 then write('w ') else write(stdOutPut,'w ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),X_OK)=0) then if tipo = 0 then write('x ') else write(stdOutPut,'x ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if tipo = 0 then write(' ',info.st_size,' bytes. ') else write(stdOutPut,' ',info.st_size,' bytes. ');
					gotoxy(35,wherey);
					if tipo = 0 then writeln(pchar(vector[J].d_name)) else writeln(stdOutPut,pchar(vector[J].d_name));
				End // fpStat
				else if tipo = 0 then writeln('No se pudo mostrar.') else writeln(stdOutPut,'No se pudo mostrar.');
			end; //for
		if tipo = 0 then writeln('- - - - - - - - - - - - - - - -') else writeln(stdOutPut,'- - - - - - - - - - - - - - - -');
		if contArchivos = 0 then if tipo=0 then writeln('No hay listado.') else writeln(stdOutPut,'No hay listado.') else
		if tipo = 0 then writeln('Nro. de archivos listados: ',contArchivos) else writeln(stdOutPut, 'Nro. de archivos listados',contArchivos);
		fpCloseDir(directorio^);
	end //openDir
	else error(4);
End;


procedure lsAF(tipo: byte);
{
	Los archivos marcados como inaccesibles son aquellos
	en los cuales fpStat devuelve un error. En dicho caso se puede saber
	el nombre del archivo, pero no datos referidos al tipo de archivo.

}

var	directorio: pdir;
	entrada: PDirent;
	vector: vDirent;
	indice,j: integer;
	K: byte;
	info: stat;

Begin
	k:= 1;
	indice:= 0;
	directorio := fpOpenDir(dirActual);
	if directorio <> nil  then
	begin	//openDir
	repeat
		entrada:= fpReadDir(directorio^);
		if (entrada <> nil) then
		begin
			inc(indice);
			vector[indice]:= entrada^;
		end;
	until entrada = nil;
	for J:= 1 to indice do
	Begin //for
		if fpStat(pchar(vector[J].d_name),info)=0 then
		Begin  //fpStat
			textattr:= $07;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25))
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write(copy(vector[J].d_name,1,25)) else write(stdOutPut,copy(vector[J].d_name,1,25):20)
					else if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln(copy(vector[J].d_name,1,25)) else writeln(stdOutPut,copy(vector[J].d_name,1,25):20);
				end;
			end; // case
			if k = 3 then k:= 1 else inc(K);
		End // fpStat
		else
		Begin // else fpStat
			textAttr:= $04;
			case K of //case
			1: 	begin
					gotoxy(1,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12))
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			2: 	begin
					gotoxy(27,wherey);
					if j <> indice then if tipo = 0 then write('Inaccesible: ',copy(vector[J].d_name,1,12)) else write(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20)
					else if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12));
				end;
			3: 	begin
					gotoxy(53,wherey);
					if tipo = 0 then writeln('Inaccesible: ',copy(vector[J].d_name,1,12)) else writeln(stdOutPut,'Inaccesible: ',copy(vector[J].d_name,1,12):20);
				end;
			end; //case
			if k = 3 then k:= 1 else inc(K);
		end; // else fpStat
	End; // for
	fpCloseDir(directorio^);
	end  // OpenDir
	else error(4);
End;


// Procedure LS -a -f -l
procedure lsAFL(tipo: byte);
{
	En caso de falla obteniendo los datos de un archivo se mostrará
	el mensaje "No se pudo mostrar.", que representa una falla en fpStat.

}

var	directorio	: Pdir;
	entrada		: PDirent;
	info		: stat;
	vector		: vDirent;
	contArchivos: integer;
	indice,j	: integer;

Begin
	indice:= 0;
	contArchivos:= 0; 	//número de archivos listados
	directorio:= fpOpenDir(dirActual);
	if directorio <> nil then
	begin //openDir
		repeat
			entrada:= fpReadDir(directorio^);
			if (entrada <> nil) then
			Begin	//if readDir
				inc(indice);
				vector[indice]:= entrada^;
			end;	//if readDir
		until entrada = nil;
		for J:= 1 to indice do
			begin //for
			if fpStat(pchar(vector[J].d_name),info)=0 then
				Begin //fpStat
				textattr:= $07;
				contArchivos:= contArchivos + 1;
					if tipo = 0 then write('Permisos: ') else write(stdOutPut,'Permisos: ');
					if (fpAccess (pchar(vector[J].d_name),R_OK)=0) then if tipo = 0 then write('r ') else write(stdOutPut,'r ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),W_OK)=0) then if tipo = 0 then write('w ') else write(stdOutPut,'w ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if (fpAccess (pchar(vector[J].d_name),X_OK)=0) then if tipo = 0 then write('x ') else write(stdOutPut,'x ') else if tipo = 0 then write('- ') else write(stdOutPut,'- ');
					if tipo = 0 then write(' ',info.st_size,' bytes. ') else write(stdOutPut,' ',info.st_size,' bytes. ');
					gotoxy(35,wherey);
					if tipo = 0 then writeln(pchar(vector[J].d_name)) else writeln(stdOutPut,pchar(vector[J].d_name));
				End // fpStat
				else if tipo = 0 then writeln('No se pudo mostrar.') else writeln(stdOutPut,'No se pudo mostrar.');
			end; //for
		textattr:= $07;
		if tipo = 0 then writeln('- - - - - - - - - - - - - - - -') else writeln(stdOutPut,'- - - - - - - - - - - - - - - -');
		if contArchivos = 0 then writeln(stdOutPut,'No hay listado.') else
		if tipo = 0 then writeln('Nro. de archivos listados: ',contArchivos) else writeln(stdOutPut, 'Nro. de archivos listados',contArchivos);
		fpCloseDir(directorio^);
	end //openDir
	else error(4);
End;


//Comando PWD
procedure pwd(tipo: byte);
Begin
	if tipo = 0 then writeln(dirActual) else writeln(stdOutPut,dirActual);
End;

procedure prueba;
Var n: cardinal;
Begin
 n:= 1;
 while n > 0 do
 begin
 writeln('p');
 inc(n);
 end;
End;


END.
