UNIT analizador;
INTERFACE


Uses crt, comandos, utilidades, unix, baseunix, sysutils, keyboard;




function analizar		(var ENTRADA: string): boolean;		// Analiza la cadena introducida por el usuario.
procedure analizarCAT	(var ENTRADA: string);				// Analiza la cadena para ejecutar el comando CAT.
function analizarCD		(var ENTRADA: string): cint;		// Analiza la cadena para ejecutar el comando CD.
function analizarEXEC	(var ENTRADA: string): cint;		// Analiza la cadena para ejecutar el comando EXEC.
procedure analizarKILL	(var ENTRADA: string);				// Analiza la cadena para ejecutar el comando KILL.
procedure analizarLS	(var ENTRADA: string);				// Analiza la cadena para ejecutar el comando LS.
procedure analizarPWD	(var ENTRADA: string);				// Analiza la cadena para ejecutar el comando PWD.
procedure analizarReDIR	(var ENTRADA: string);				// Analiza la cadena si presenta redirección de la salida estándar.
procedure analizarPipe	(var ENTRADA: string);				// Analiza la cadena si presenta pipes (tuberías).
procedure analizarFG (var ENTRADA: string);                 // Analiza la cadena para ejecutar el comando fg ( las señales se ejecutan en esta unit)
procedure analizarSegundoPlano (var ENTRADA: string);       // Analiza la cadena para ejecutar en 'segundo plano' con el simbolo & al final.
procedure analizarBG(var ENTRADA:string);                   // Analiza la cadena para pasar un proceso en 'primer plano' a 'segundo plano'.
function primerPalabra(ENTRADA:string):string;

IMPLEMENTATION
function primerPalabra(ENTRADA:string):string;
begin
primerPalabra:='';
primerPalabra:=(copy(upcase(ENTRADA),1,espacio(ENTRADA)-1));
end;


function analizar(var ENTRADA: string): boolean;
var F:TArchivoRedireccion;
    TempHout:longint;
    interno:boolean;
Begin

interno:=false;
analizar := true;
       	if (primerPalabra(ENTRADA) = 'EXIT') or (primerPalabra(ENTRADA) ='BG') or (primerPalabra(ENTRADA) ='&') or (primerPalabra(ENTRADA) ='JOBS')or (primerPalabra(ENTRADA) ='FG') or (primerPalabra(ENTRADA) ='CLEAR') or (primerPalabra(ENTRADA) ='CAT') or (primerPalabra(ENTRADA) ='CD') or (primerPalabra(ENTRADA) ='KILL') or (primerPalabra(ENTRADA) ='LS') or  (primerPalabra(ENTRADA) ='PWD') then
       	interno:=true;
			if (interno= true) and (tuberiaoredi <> '') then  
				begin
				case tuberiaoredi[1] of
				
				'1': CambiarSalidaAArchivo(F,TempHout,tuberiaoredi[2],ruta);
				'2': CambiarEntradaAArchivo(F,TempHout,ruta);
								    
			    end
			end;
      	//else begin
       if upcase(ENTRADA)='EXIT' then analizar:= false		// Salir del programa.
        else begin
           if (copy(upcase(ENTRADA),1,2))='BG' then analizarBG(ENTRADA) // Pasar un programa en primer plano a segundo plano
           else begin
         if (copy(upcase(ENTRADA),length(ENTRADA),1))= '&' then analizarSegundoPlano(ENTRADA)  //Ejecutar el proceso enla entrada en 'segundo plano'

           else begin
             if (copy(upcase(ENTRADA),1,4)) = 'JOBS' then Jobs  // Array con informacion de cada proceso, incluyendo prioridades y estado.
             else begin
                if (copy(upcase(ENTRADA),1,2))='FG'  then analizarFG(ENTRADA) //Traer un proceso detenido en segundo plano a ejecucion en primero.
                                                                              //Si no se especifica el pid del proceso, se ejecuta el de mayor prioridad (que contenga '+')
                 else begin
                   if upcase(ENTRADA)='CLEAR' then clrscr			// Limpiar la pantalla.
	              else begin
			if	redireccion(ENTRADA) = true then analizarReDIR(ENTRADA)		// Redirección de la salida estándar.
			else begin
				if tuberia(ENTRADA) then analizarPipe(ENTRADA)			// Tubería (pipe).
				else begin
					if (copy(upcase(ENTRADA),1,3))='CAT' then analizarCAT(ENTRADA)		// Comando CAT
					else begin
						if (copy(upcase(ENTRADA),1,2))='CD' then analizarCD(ENTRADA)	// Comando CD
						else begin
							if (copy(upcase(ENTRADA),1,4))='KILL' then analizarKILL(ENTRADA)	// Comando KILL
							else begin
								if (copy(upcase(ENTRADA),1,2))='LS' then 
								 analizarLS(ENTRADA)	// Comando LS
								else begin
									if (copy(upcase(ENTRADA),1,3))='PWD' then analizarPWD(ENTRADA)	//Comando PWD
									else
									begin
										if ENTRADA <> '' then
										Begin
											if analizarEXEC(ENTRADA) = -1 then
											error(5); //Comando no reconocido.
										    end;

                                        end;
								    end;
								end;
							end;
						end;
					end;
				end;
		//	end;
		end;
	  END;
     end;
	End;
   end;
  end;
  if (interno= true) and (tuberiaoredi <> '') then  
				begin
				case tuberiaoredi[1] of
				'1': CambiarSalidaAPantalla(F,TempHout);
				'2': CambiarEntradaATeclado(F,TempHout);
				
				    
			    end
			end;
			
tuberiaoredi:='';
end;

procedure analizarBG(var ENTRADA:string);
var code,i: integer;
    q: string;


begin
q:= copy((ENTRADA),4,8);
Val(q,i,code);
hijoFin:=false;
gol:=false;

if (i <> 0) then
begin
if pidCoinciden(i)=false then
       writeln('Error en el PID')
         else begin

			if pidCoinciden(i)=true then
			kill(SIGCONT,i);
end
end
else begin
writeln('Ingrese PID');
end;
end;



procedure analizarSegundoPlano(var ENTRADA: string);
var
   q:string;
   pid:longint;


begin

 q:= (copy((ENTRADA),1,(length(ENTRADA))-2));
pid:=fpFork;
case pid of
-1: writeln('error en el fork');
0: begin

fpexeclp(q,[]);
end;
else begin
asignarJobs(pid,q);
end;
end;
 end;



procedure analizarFG (var ENTRADA: string); // Error: //si se presiona cualquier tecla antes que
                                                      //termine la ejecucion del proceso despues del fg,
                                                      //sale correctamente. Si no no.
var code,i,h: integer;
    q: string;


begin
q:= copy((ENTRADA),4,8);
Val(q,i,code);
hijoFin:=false;
gol:=false;



if (i <> 0) then  //fg con argumentos. se le pasa un pid, visible haciendo un jobs del proceso que se quiere renaudar
begin
	if pidCoinciden(i)=false then
       writeln('Error en el PID')
         else begin

			if pidCoinciden(i)=true then
			 begin
				 kill(18,i);
				 espera(i);
			
				  if gol <> true then      //si no se presiono un ctrl+z o ctrl+c
				begin
				 if waitprocess(i) >= 0 then  // Si la finalizacion del proceso es satisfactoria
					begin
					writeln('Proceso terminad0')
					end
				end
		
			 end;


      end;
  end

else begin
if i=0 then    // fg sin argumento. Busca el proceso de mayor prioridad y lo trae a primer plano
begin
if buscarPrioridad('+')=true then
h:=buscarPid('+');
			 begin
				 kill(18,h);
				 espera(h);
			
				  if gol <> true then
				begin
				 if waitprocess(h) >= 0 then
					begin
					writeln('Proceso terminado')
					end
				end
				end
				end;
end;
				
end;

	

procedure analizarCAT(var ENTRADA: string);
var dir1, dir2: string;
	tipo: byte;
Begin
	if strOutPut = '' then tipo := 0 else tipo := 1; // Tipo 0: Salida estándar, tipo 1: Redirigir la salida.
	dir1 := copy(ENTRADA,5,proxEspacio(5,ENTRADA)-1);
	if dir1 = '' then error(1)
	else
		begin
			dir2 := obtenerDirectorio(length(dir1)+5,ENTRADA);
			if dir1[1] <> '/' then dir1 := dirActual+'/'+dir1;
			if (dir2 <> '') and (dir2[1] <> '/') then dir2 := dirActual+'/'+dir2;
			CAT (dir1,dir2,tipo);
		end;
End;



function analizarCD(var ENTRADA: string): cint;
{
	Nombre: analizarCD.
	return: -1 si hay error, 0 si se ejecutó con éxito.
}

Begin
	analizarCD:= 0;
	if (length(ENTRADA) = 2) or ((length(ENTRADA) = 3) and (ENTRADA[3]=' ')) then fpChDir(fpGetEnv('HOME'))
	else
		begin
			if (length(ENTRADA) = 5) and (copy(ENTRADA,4,2) = '..') then fpChDir('..')
			else
				begin
					if ENTRADA[4] = '/' then
					Begin
						if fpChDir(copy(ENTRADA,4,length(ENTRADA))) <>0 then
						if fpChDir(dirActual + copy(ENTRADA,4,length(ENTRADA))) <> 0 then
							begin
								analizarCD:= -1;
								error(4);
							end;
					End
					else
					Begin
						if fpChDir(copy(ENTRADA,4,length(ENTRADA))) <>0 then
						if fpChDir(dirActual + '/' + copy(ENTRADA,4,length(ENTRADA))) <> 0 then
							begin
								analizarCD:= -1;
								error(4);
							end;
					End;
				end;
		end;
End;



function analizarEXEC(var ENTRADA: string): cint;
{
   Nombre: analizarEXEC.
   Condición: No se permiten más de 3 parámetros.

}

var cadena	: string;
	aux		: string;

Begin


      analizarExec := 0;
		cadena:= copy(ENTRADA,1,espacio(ENTRADA)-1);
		aux:= copy(ENTRADA,length(cadena)+2,length(ENTRADA));
		if ((cadena[1] <> '/') and (FSearch (cadena,strpas(fpGetenv('PATH'))) <> ''))
		or ((cadena[1] = '/') and (fileExists(cadena))) then
		begin
			case cantArgumentos(aux) of	// 0, 1, 2 o 3 parámetros.
			0: EXEC(cadena,[]);
			1: EXEC(cadena,[argumento(1,aux)]);
			2: EXEC(cadena,[argumento(1,aux),argumento(2,aux)]);
			3: EXEC(cadena,[argumento(1,aux),argumento(2,aux),argumento(3,aux)]);
			end;

		end
		else
			analizarExec:= -1;

End;



procedure analizarKILL(var ENTRADA: string);
{
   Nombre: analizarKILL.
   Condición: Deben pasarse dos parámetros, sin excepción.

}

var str1,str2: string;
	proc,signal: longint;
	err: word;
Begin
	str1:= copy(ENTRADA,6,length(ENTRADA));
	str2:= copy(str1,1,espacio(str1)-1);
	val(str2,signal,err);
	if err<>0 then error(9) else
		begin
		str2:= copy(str1,espacio(str1)+1,length(str1));
		val(str2,proc,err);
		if err<>0 then error(9)
		else KILL(signal,proc);
		end;
End;



procedure analizarLS(var ENTRADA: string);
{
   Nombre: analizarLS.
   Opciones: Puede haber 0, 1, 2 o 3 parámetros identificados con un guión <->
			 y pueden estar en cualquier orden. Estos son <-a>, <-f>, <-l>.
			 Puede haber o no 1 argumento que indique la ruta desde la cual
			 trabajar, luego de los parámetros comenzados con guión.

}

var directorio,cad,dirBase: string;
	err2,err8: boolean;			// Hacen referencia a los errores 2 y 8 respectivamente.
	correcto: boolean;
	tipo	: byte;

Begin
	err2:= false;
	err8:= false;
	correcto:= false;
	dirBase:= dirActual;
	if strOutPut = '' then tipo := 0 else tipo := 1;	// Tipo 0: Salida estándar, tipo 1: Redirigir la salida.
	directorio:= obtenerDirectorio(4,ENTRADA);
	case cantParametros(ENTRADA) of
	0: 	begin
		if directorio = '' then ls(tipo) else
			begin
			cad:= 'cd ' + directorio;
			if analizarCD(cad) = 0 then ls(tipo);
			cad:= 'cd ' + dirBase;
			analizarCD(cad);
			end;
		end;
	1:  begin
		 if upcase(parametro(1,ENTRADA)[2]) = 'L' then
			// Si el parámetro es -l
			begin
			if directorio = '' then lsL(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsL(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if (upcase(parametro(1,ENTRADA)[2]) <> 'A') and (upcase(parametro(1,ENTRADA)[2]) <> 'F') then err8:= true;

		  if upcase(parametro(1,ENTRADA)[2]) = 'F' then
			// Si el parámetro es -f
			begin
			if directorio = '' then lsF(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsF(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if (upcase(parametro(1,ENTRADA)[2]) <> 'A') and (upcase(parametro(1,ENTRADA)[2]) <> 'L') then err8:= true;
			// Si el parámetro es -a
		 if upcase(parametro(1,ENTRADA)[2]) = 'A' then
			begin
			if directorio = '' then lsA(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsA(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if (upcase(parametro(1,ENTRADA)[2]) <> 'L') and (upcase(parametro(1,ENTRADA)[2]) <> 'F') then err8:= true;
		end;
	2:	begin
		 if ((upcase(parametro(1,ENTRADA)[2]) = 'L') and (upcase(parametro(2,ENTRADA)[2]) = 'F'))
		 or ((upcase(parametro(2,ENTRADA)[2]) = 'L') and (upcase(parametro(1,ENTRADA)[2]) = 'F')) then
			// Si los parámetros son -l y -f
			begin
			if directorio = '' then lsLF(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsLF(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if not ((((upcase(parametro(1,ENTRADA)[2]) = 'L') or (upcase(parametro(1,ENTRADA)[2]) = 'A')) or (upcase(parametro(1,ENTRADA)[2]) = 'F'))
			   and (((upcase(parametro(2,ENTRADA)[2]) = 'L') or (upcase(parametro(2,ENTRADA)[2]) = 'A')) or (upcase(parametro(2,ENTRADA)[2]) = 'F'))) then err8:= true;

		 if ((upcase(parametro(1,ENTRADA)[2]) = 'L') and (upcase(parametro(2,ENTRADA)[2]) = 'A'))
		 or ((upcase(parametro(2,ENTRADA)[2]) = 'L') and (upcase(parametro(1,ENTRADA)[2]) = 'A')) then
			// Si los parámetros son -l y -a
			begin
			if directorio = '' then lsLA(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsLA(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if not ((((upcase(parametro(1,ENTRADA)[2]) = 'L') or (upcase(parametro(1,ENTRADA)[2]) = 'A')) or (upcase(parametro(1,ENTRADA)[2]) = 'F'))
			   and (((upcase(parametro(2,ENTRADA)[2]) = 'L') or (upcase(parametro(2,ENTRADA)[2]) = 'A')) or (upcase(parametro(2,ENTRADA)[2]) = 'F'))) then err8:= true;

		 if ((upcase(parametro(1,ENTRADA)[2]) = 'A') and (upcase(parametro(2,ENTRADA)[2]) = 'F'))
		 or ((upcase(parametro(2,ENTRADA)[2]) = 'A') and (upcase(parametro(1,ENTRADA)[2]) = 'F')) then
			// Si los parámetros son -a y -f
			begin
			if directorio = '' then lsAF(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsAF(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
			end
			else
			if not ((((upcase(parametro(1,ENTRADA)[2]) = 'L') or (upcase(parametro(1,ENTRADA)[2]) = 'A')) or (upcase(parametro(1,ENTRADA)[2]) = 'F'))
			   and (((upcase(parametro(2,ENTRADA)[2]) = 'L') or (upcase(parametro(2,ENTRADA)[2]) = 'A')) or (upcase(parametro(2,ENTRADA)[2]) = 'F'))) then err8:= true;
		end;
	3:	begin
		case (upcase(parametro(1,ENTRADA)[2])) of
		'L': 	begin
				if (upcase(parametro(2,ENTRADA))[2]) = 'F' then begin
					if (upcase(parametro(3,ENTRADA))[2]) = 'A' then correcto:= true; end
					else
					if (upcase(parametro(2,ENTRADA))[2]) = 'A' then
						if (upcase(parametro(3,ENTRADA))[2]) = 'F' then correcto:= true;
				end;
		'F': 	begin
				if (upcase(parametro(2,ENTRADA)[2])) = 'L' then begin
					if (upcase(parametro(3,ENTRADA)[2])) = 'A' then correcto:= true; end
					else
					if (upcase(parametro(2,ENTRADA)[2])) = 'A' then
						if (upcase(parametro(3,ENTRADA)[2])) = 'L' then correcto:= true;
				end;
		'A': 	begin
				if (upcase(parametro(2,ENTRADA)[2])) = 'F' then begin
					if (upcase(parametro(3,ENTRADA)[2])) = 'L' then correcto:= true; end
					else
					if (upcase(parametro(2,ENTRADA)[2])) = 'L' then
						if (upcase(parametro(3,ENTRADA)[2])) = 'F' then correcto:= true;
				end;
		else err2:= true;
		end;
		if correcto then
		// Si los parámetros son 3 y son -a, -f, -l en cualquier orden.
		begin
			if directorio = '' then lsAFL(tipo) else
				begin
				cad:= 'cd ' + directorio;
				if analizarCD(cad) = 0 then lsAFL(tipo);
				cad:= 'cd ' + dirBase;
				analizarCD(cad);
				end;
		end
		else err2:= true;
		end;
	end;
	if err2 then error(2) else
	if err8 then error(8);
End;


procedure analizarPWD(var ENTRADA: string);
{
   Nombre: analizarPWD.

}
var tipo: byte;
Begin
	if strOutPut = '' then tipo := 0 else tipo := 1;	// Tipo 0: Salida estándar, tipo 1: Redirigir la salida.
	if (ENTRADA[0] >= #4) and not (flagInPut) then error(2)
	else pwd(tipo);
End;


procedure analizarReDIR	(var ENTRADA: string);
var	comando: string;
	i,j: word;
    	u:string;	

	Begin
	redi1:=true;
	i:= pos(' > ',ENTRADA);
	j:= pos(' >> ', ENTRADA);

	
	if i <> 0 then
		begin	// > rewrite (reescribe el archivo, lo crea si no existe).
	
	     u:=(copy((ENTRADA),1,i));	
	     
		  ruta:=copy(ENTRADA,i+3,length(ENTRADA));
		       tuberiaoredi:='1'+'1';
		      analizar(u);
			
		
		end;
	if j <> 0 then
		begin	// >> append (añade los datos al final del archivo).
			
			
	         u:=copy(ENTRADA,1,j);	
			ruta:=copy(ENTRADA,j+4,length(ENTRADA));
			    tuberiaoredi:='1'+'2';
			     analizar(u);
						
			
		end;
End;


procedure analizarPipe(var ENTRADA: string);
var i: word;
	aux, preString, postString: string;
 
Begin
	i:= pos(' | ',ENTRADA);
	preString	:= copy(ENTRADA, 1, i-1);
	postString	:= copy(ENTRADA, i+3, length(ENTRADA));

	tuberiaoredi:='1' + '1';
   
   
   ruta:='/home/facundo/salida';
   
   analizar (preString);
   tuberiaoredi:='2' + '1';
   analizar (postString);  
		


END;

end.
