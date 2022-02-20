unit biotoolkit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Graphics, Dialogs, Forms, Controls, Menus,
  StdCtrls, ExtCtrls;

//DEFINICIÓN DE TIPOS

type

  TPunto = record
    (*
    Representa un punto el espacio tridimensional
    *)
    X,Y,Z: real;
  end;

  TPuntos = array of TPunto;

  TAtomPDB = record
      (*
      Representa un átomo de un archivo PDB, por lo
      que guardará la información de los átomos que se da en dichos archivos:
          NumAtom: Número del átomo
          ID: Identificador del átomo
          residuo: Residuo al que pertenece el átomo
          subunidad: Subunidad a la que pertenece el átomo
          NumRes: Número del residuo al que pertenece el átomo
          coor: TPunto que guarda la información de las coordenadas del átomo
          R: Factor temperatura del átomo
      *)

    NumAtom: integer;
    ID: string;
    residuo: string;
    subunidad: char;
    NumRes: integer;
    coor: Tpunto;
    R: real;
  end;

  TResiduoPDB = record
  (*
  Representa un residuo de un archivo PDB
     NumRes: Número del residuo
     Subunidad: Subunidad a la que pertenece
     ID1: Código de 1 letra de un aminoácido
     ID3: Código de 3 letras de un aminoácido
     atm1, atmN: 1º y último átomos
     N, CA, C, O: Número de átomos
     phi, psi: ángulos diedros
  *)
    NumRes: integer;
    Subunidad: char;
    ID1: char;
    ID3: string;
    atm1, atmn: integer;
    N, CA, C, O: integer;
    phi, psi: real;
  end;

  TsubunidadPDB = record
    (*
    Representa una subunidad de un archivo PDB
      ID: Identificador de la subunidad
      atm1, atmN, res1, resN: 1º y último átomo y residuo
      ResIndex: Índice del residuo
    *)
    ID: char;
    atm1, atmN, res1, resN: integer;
    atomCount, resCount: integer;
    ResIndex: array of integer;
  end;

  TPDB = record
    (*
    Representa un archivo PDB completo
       header: 1ª Línea, encabezado
       atm, res, sub: Arrays con la información de átomos, residuos y subunidades
       NumFichas, NumResiduos, NumSubunidades: número de átomos, res. y subunidades
       subs, secuencia: Cadenas de caracteres de las subunidades y secuencia
    *)
    header: string;
    atm: array of TAtomPDB;
    res: array of TResiduoPDB;
    sub: array of TsubunidadPDB;
    NumFichas, NumResiduos, NumSubunidades: integer;
    subs, secuencia: string;
  end;

  TTablaDatos = array of array of real;
  TTransformTPuntoFunc = function(a: real; X:TPunto): TPunto;

//DEFINICIÓN DE CONSTANTES PÚBLICAS

const
   AA = '    ALA-A ARG-R ASN-N ASP-D CYS-C GLN-Q GLU-E GLY-G HIS-H ILE-I'
    +' LEU-L LYS-K MET-M PHE-F PRO-P SER-S THR-T TRP-W TYR-Y VAL-V';

//PUBLICACIÓN DE FUNCIONES

//funciones formato
function AA3to1 (AA3: string): char;
function AA1to3 (AA1: char): string;

//funciones vectores
function modulo(V: TPunto): real;
function angulo(A, B: TPunto): real;
function angulo(A, B, C: TPunto): real; overload;
function distancia3D(p1, p2: Tpunto): real; overload;
function distancia3D(a1, b1, c1, a2, b2, c2: real): real;
function prodVectorial(A, B: TPunto): TPunto;
function torsion (A, B, C, D: TPunto): real;
function prodEscalar(A, B: TPunto): real;
function sumaV(A, B: TPunto): TPunto;
function diferenciaV(A, B: TPunto): TPunto;
function EscalarV(k: real; V: TPunto): TPunto;

//funciones PDB y otros formatos
function CargarPDB(texto: TStrings): TPDB; overload;
function cargarPDB(var p: TPDB): string;
function extraerSecuencia(texto: TStrings; formato: string): string;
function writePDB(atm: TAtomPDB): string;


//funciones gráficas
function PlotXY(datos: TTablaDatos; im: TImage; OX: integer = 0;
                OY: integer =1; borrar: boolean = False;
                linea: boolean = False;
                clpluma: TColor = clyellow;
                clrelleno: TColor = clyellow;
                clFondo: TColor = clBlack;
                radio: integer = 3; borde: integer = 5;
                marcarFin: boolean = False; clfin: TColor = clred): boolean;


//funciones movimiento de proteínas
function traslacion(dx, dy, dz: real; V: TPunto): TPunto;
function traslacion(dx, dy, dz: real; datos: TPuntos): TPuntos; overload;
function traslacion(dx, dy, dz: real; var p: TPDB): integer; overload;
function GiroOX(rad: real; V: TPunto): TPunto;
function GiroOX(rad: real; datos: TPuntos): TPuntos; overload;
function GiroOX(rad: real; var p: TPDB): integer; overload;
function GiroOY(rad: real; V: TPunto): TPunto;
function GiroOY(rad: real; datos: TPuntos): TPuntos; overload;
function GiroOY(rad: real; var p: TPDB): integer; overload;
function GiroOZ(rad: real; V: TPunto): TPunto;
function GiroOZ(rad: real; datos: TPuntos): TPuntos; overload;
function GiroOZ(rad: real; var p: TPDB): integer; overload;
function Alinear_eje_Z(puntos: TPuntos): TPuntos;

implementation

//FUNCIONES FORMATO

function AA3to1 (AA3: string): char;
{
Función para pasar aminoácidos de código de 3 letras a código de 1 letra

  :Parámetros:
      :param AA3: aminoácido en código de 3 letras
  :salida:
      :char: aminoácido en código de 1 letra
}
    begin
       result:= AA[pos(AA3, AA) + 4];
    end;

function AA1to3 (AA1: char): string;
{
Función inversa a AA3to1()
}
var index: integer;
  begin
     index:=pos(AA1, AA)-1;
     result:= copy(AA, index, 3);
  end;

//FUNCIONES VECTORES

function modulo(V: TPunto): real;
(*
Función para calcular el módulo de un vector

:Parámetros:
     :param V: Vector, tipo TPunto
:Salida:
  :real: Valor del módulo
*)

  begin
    result := sqrt(sqr(V.X) + sqr(V.Y) + sqr(V.Z));
  end;

function angulo(A, B: TPunto): real;
(*
Función para calcular el ángulo formado por dos vectores

:Parámetros:
  :param A: Primer punto
  :param B: Segundo punto
:Salida:
  :real: Valor del ángulo
*)
  var
    numerador, denominador: real;
  begin
    numerador:= prodEscalar(A, B);
    denominador:= modulo(A)*modulo(B);
    if denominador > 0
       then result := arccos(numerador/denominador)
    else result := maxfloat;
  end;

function angulo(A, B, C: TPunto): real; overload;
(*
Función para calcular el ángulo formado por 3 puntos (dos vectores)

:Parámetros:
  :param A: Primer punto
  :param B: Segundo punto
  :param C: Punto que actúa como vértice
:Salida:
  :real: Valor del ángulo
*)
  var
    BA, BC: TPunto;
  begin
    BA:= diferenciaV(A, B);
    BC:= diferenciaV(C, B);
    result:= angulo(BA, BC);
  end;

function distancia3D(a1, b1, c1, a2, b2, c2: real): real;
  begin
   result :=sqrt(sqr(a1-a2)+sqr(b1-b2)+sqr(c1-c2));
  end;

function distancia3D(p1, p2: Tpunto): real; overload;
  begin
   result :=sqrt(sqr(p1.X-p2.X)+sqr(p1.Y-p2.Y)+sqr(p1.Z-p1.Z));
  end;

function prodVectorial(A,B: TPunto): TPunto;
(*
Función para calculas el producto vectorial de
dos vectores

:Parámetros:
  :param A, B: Vectores cuyo producto vectorial se calcula
:Salida:
  :TPunto: Vector resultante
*)
  var
    V:TPunto;
  begin
    V.X := A.Y*B.Z - A.Z*B.Y;
    V.Y := A.Z*B.X - A.X*B.Z;
    V.Z := A.X*B.Y - A.Y*B.X;
    result := V;
  end;

function torsion (A, B, C, D: TPunto): real;
(*
Función para calcular el ángulo de torsión
formado por 4 puntos contiguos

:Parámetros:
  :param A, B, C, D: Puntos
:Salida:
  :real: Valor del ángulo de torsión
*)
  var
      BA, BC, CB, CD, V1, V2, P: TPunto;
      denominador, diedro, diedro_iupac, cosGamma: real;
    begin
      diedro_iupac:= 0;
      BA:= diferenciaV(A,B);
      BC:= diferenciaV(C,B);
      CB:= diferenciaV(B,C);
      CD:= diferenciaV(D,C);
      V1 := prodVectorial(BC, BA);
      V2 := prodVectorial(CD, CB);
      diedro := angulo(V1, V2);
      P:= prodVectorial(V2, V1);
      denominador:= modulo(P)*modulo(CB);
      if denominador > 0 then
        begin
          cosGamma:= prodEscalar(P, CB)/denominador;
          if cosGamma > 0 then cosGamma:= 1 else cosGamma:= -1;
        end else diedro_iupac:= maxfloat;
      if diedro < maxfloat then diedro_iupac:= diedro*cosGamma;
        result:= diedro_iupac;
    end;

function prodEscalar(A, B: TPunto): real;
(*
Función para calcular el producto escalar de dos vectores

:Parámetros:
  :param A, B: Vectores cuyo producto vectorial se calcula
:Salida:
  :real: Valor del escalar resultante
*)
  begin
    result:= A.X * B.X + A.Y*B.Y + A.Z*B.Z;
  end;

function sumaV(A, B: TPunto): TPunto;
  var
    V: TPunto;
  begin
    V.X := A.X + B.X;
    V.Y := A.Y + B.Y;
    V.Z := A.Z + B.Z;
    result:= V;
  end;

function diferenciaV(A, B: TPunto): TPunto;
  var
    V: TPunto;
  begin
    V.X := A.X - B.X;
    V.Y := A.Y - B.Y;
    V.Z := A.Z - B.Z;
    result:= V;
  end;

function EscalarV(k: real; V: TPunto): TPunto;
  begin
    result.X := k*V.X;
    result.Y := k*V.Y;
    result.Z := k*V.Z;
  end;

//FUNCIONES PDB Y OTROS FORMATOS

function writePDB(atm: TAtomPDB):string;
(*
Función que escribe líneas que contienen la información
sobre un átomo en formato PDB
:parámetros:
   :param atm: átomo cuya info se escribe, de tipo TAtomPDB
:salida:
   :string: contiene la información del átomo
*)
var
   natm, nres, X, Y, Z, R, linea: string;
begin
  natm:= inttostr(atm.NumAtom);
  nres:= inttostr(atm.NumRes);
  X:= formatfloat('0.000', atm.coor.X);
  Y:= formatfloat('0.000', atm.coor.Y);
  Z:= formatfloat('0.000', atm.coor.Z);
  R:= formatfloat('0.00', atm.R);
  linea:= 'ATOM  ' +
          format('%5s', [natm]) + //5 caracteres alineados a la dcha
          '  ' + //espacio que hay entre las columnas
          format('%-3s', [atm.ID]) + //4 caracteres  alineados a la izq
          ' ' + //omitimos altLoc
          atm.residuo +
          '  ' + //saltamos columna vacía y ChainID
          format('%4s', [nres]) +
          '    ' + //omitimos iCode y 3 columnas vacías
          format('%8s', [X]) +
          format('%8s', [Y]) +
          format('%8s', [Z]) +
          format('%6s', ['1.00']) + //misma ocupancia, 1.00 para todos los
                                    //átomos y dos espacios a la izq
          format('%6s', [R]) + //factor temperatura con 1 espacio a la izq
          '              '; //incluimos 14 espacios para mantener el mismo formato
  result:= linea;
end;

function extraerSecuencia(texto: TStrings; formato: string): string;
(*
Función para extraer una secuencia de proteína en diferentes tipos
de archivos.
   :Parámetros:
      :param texto: Es el texto generado a partir del archivo seleccionado
      :param formato: Tipo de formato (PDB, EMBL, FASTA, UniProt o GenBank)
   :returns:
      :string: Contiene la secuencia o el aviso de que el formato elegido no
               está soportado
*)
  var
    j: integer; //índice para los bucles
    sec, linea: String;
    p: TPDB;
  begin
     if formato = 'PDB' then
       begin
         p:= CargarPDB(texto);
         result:= p.secuencia;
       end
     else if formato = 'UniProt' then
        begin
          for j:= 0 to texto.count-1 do
            begin
              linea:=texto[j];
              if copy(linea, 0, 2) = '//' then Break;
              sec:= sec + trim(linea);
              if copy(linea, 0, 2) = 'SQ' then sec:= '';
            end;
            result:= trim(sec);
        end
     else if formato = 'GenBank' then
        begin
          sec:='';
          for j:= 0 to texto.count-1 do
            begin
               linea:= texto[j];
               if copy(linea,0,6) = 'ORIGIN' then Break;
               sec:= sec + trim(linea);
               if copy(linea,22,13) = '/translation=' then sec:= copy(linea, 35, 70);
            end;
            result:= trim(copy(sec,2,sec.Length-2));
        end

     else if formato = 'EMBL' then
         begin
           sec:= '';
           for j:= 0 to texto.count-1 do
             begin
                linea:= texto[j];
                if (copy(linea,0,2) = 'XX') and (copy(texto[j+1],0,2) = 'SQ') then Break;//para que pare en el último XX que hay
                sec:= sec + trim(copy(linea,22,58));
                if copy(linea, 22, 13) = '/translation=' then sec:= copy(linea, 35, 39);
             end;
         result:= trim(copy(sec,2,sec.Length-2));
         end

     else if formato = 'FASTA' then
          begin
            sec:='';
            for j:=1 to texto.count-1 do //empezamos en 1 porque queremos saltar la primera línea
              linea:= texto[j];
              begin
                 sec:= sec + trim(linea)
              end;
         result:= trim(sec);
          end
     else
         result:='Formato no soportado';
end;



function cargarPDB(var p: TPDB): string;
 (*
Función para cargar un fichero PDB en un tipo TPDB, definido anterioremente
:parámetros:
   :param p: TPDB: Crea un TPDB y lo asigna a la variable p
:returns:
   :string: Contenido del TPDB
*)
  var
    dialogo: TOpenDialog;
    textoPDB: TStrings;
  begin
     dialogo:= TOpenDialog.create(application);
     textoPDB:= TStringlist.create;

     if dialogo.execute then
       begin
        textoPDB.loadfromfile(dialogo.filename);
        p:=cargarPDB(textoPDB);
        result:= dialogo.filename;

       end else result:= '';

     dialogo.free;
     textoPDB.free;
  end;

function CargarPDB(texto: TStrings): TPDB; overload;
(*
Función para cargar un fichero PDB en un tipo TPDB, definido anterioremente
:parámetros:
   :param texto: TStrings que contiene la información del PDB
:returns:
   :TPDB: record de tipo TPDB con la información del archivo PDB
*)
  var
    j, k, F, R, S: integer;
    p: TPDB;
    linea: string;
    resno: integer;
  begin
    //ponemos los contadores a 0
    F:=0;
    R:= 0;
    S:= 0;

    //iniciamos como cadena vacía
    p.secuencia:= '';
    p.subs := '';

    //asignamos longitud sobreestimándola
    setLength(p.atm, texto.count);
    setLength(p.res, texto.count);
    setLength(p.sub, texto.count);

    for j:= 0 to texto.count-1 do
    begin
     linea:= texto[j];
     if copy(linea, 1, 6) = 'ATOM  ' then
     begin
       F:= F +1;

       p.atm[F].NumAtom:= strtoint(trim(copy(linea, 7, 5)));
       p.atm[F].ID:= trim(copy(linea, 13, 4));
       p.atm[F].residuo:= trim(copy(linea, 18, 3));
       p.atm[F].subunidad:=linea[22];
       p.atm[F].NumRes:= strtoint(trim(copy(linea, 23, 4)));
       p.atm[F].coor.X:=strtofloat(trim(copy(linea, 31, 8)));
       p.atm[F].coor.Y:=strtofloat(trim(copy(linea, 39, 8)));
       p.atm[F].coor.Z:=strtofloat(trim(copy(linea, 47, 8)));
       p.atm[F].R :=strtofloat(trim(copy(linea, 61, 6)));

       if p.atm[F].ID = 'N' then
          begin
            R:= R+1;
            p.res[R].NumRes := p.atm[F].NumRes;
            p.res[R].subunidad := p.atm[F].subunidad;
            p.res[R].ID3 := p.atm[F].residuo;
            p.res[R].ID1 := aa3to1(p.res[R].ID3);
            p.secuencia := p.secuencia + p.res[R].ID1;
            p.res[R].atm1 := F;
            p.res[R].N := F;

            if pos(p.atm[F].subunidad, p.subs)=0 then
               begin
                 S:= S+1;
                 p.subs:= p.subs + p.atm[F].subunidad;
                 p.sub[S].ID:= p.atm[F].subunidad;
                 p.sub[S].atm1:= F;
                 p.sub[S].res1:= R;

               end;
          end;

       if p.atm[F].ID = 'CA' then p.res[R].CA := F;
       if p.atm[F].ID = 'C' then p.res[R].C := F;
       if p.atm[F].ID = 'O' then p.res[R].O := F;
       p.res[R].atmN:= F;
       p.sub[S].atmN:= F;
       p.sub[S].resN:= R;

     end;
     end;
     p.NumFichas:= F;
     p.NumResiduos:= R;
     p.NumSubunidades:= S;
     setLength(p.atm, F+1);
     setLength(p.res, R+1);
     setLength(p.sub, S+1);

     for j:=1 to p.NumSubunidades do with p.sub[j] do
     begin
      AtomCount:= atmN - atm1 +1;
      ResCount:= resN-res1 +1;
      for k:= p.sub[j].res1 +1 to p.sub[j].resN -1 do
      begin
          p.res[k].phi:=torsion(p.atm[p.res[k-1].C].coor,
                                p.atm[p.res[k].N].coor,
                                p.atm[p.res[k].CA].coor,
                                p.atm[p.res[k].C].coor);

          p.res[k].psi:=torsion(p.atm[p.res[k].N].coor,
                                p.atm[p.res[k].CA].coor,
                                p.atm[p.res[k].C].coor,
                                p.atm[p.res[k+1].N].coor);

        end;

        setlength(p.sub[j].resindex, p.NumResiduos + 1);
        for k:=1 to p.sub[j].ResCount do
        begin
          resno:= p.sub[j].res1 + k - 1;
          p.sub[j].resindex[p.res[resno].numres]:= resno;
        end;
      end;
      result:=p;
    end;



//FUNCIONES GRÁFICAS

function PlotXY(datos: TTablaDatos; im: TImage; OX: integer = 0;
                OY: integer =1; borrar: boolean = False;
                linea: boolean = False;
                clpluma: TColor = clyellow;
                clrelleno: TColor = clyellow;
                clFondo: TColor = clBlack;
                radio: integer = 3; borde: integer = 5;
                marcarFin: boolean = False; clfin: TColor = clred): boolean;
(*
Función para dibujar una gráfica
:Parámetros:
   :param datos: Datos que se van a dibujar en formato TTablaDatos
   :param im: TImage en la que se va a dibujar la gráfica
   :param OX: Eje X
   :param OY: Eje Y
   :param borrar: Variable booleana para borrar la pisible gráfica
                  preexistente
   :param linea: Variable booleana para pintar o no una línea
   :param clpluma: Color de la pluma
   :param clrelleno: Color del relleno de cada punto
   :param clFondo: Color del fondo de TImage
   :param radio: Radio de los puntos
   :param borde: Borde del TImage donde se dibuja la gráfica
   :param marcarFin: Boolean para marcar el último punto
   :param clfin: Color del último punto si marcarFin == True
:salida:
   :boolean: variable booleana que marca el comienzo y el fin de la gráfica
*)
  var
    j: integer;
    xp, yp: integer;
    xmin, xmax, ymin, ymax, rangox, rangoy: real;
    ancho, alto: integer;
    OK: boolean;

    function XPixel(x:real): integer;
      begin
          result:= round(((ancho-2*borde)*(x-xmin)/rangox)+borde);
      end;

    function YPixel(y:real): integer;
      begin
          result:= round(alto-(((alto-2*borde)*(y-ymin)/rangoy)+borde));
      end;

  begin
    OK:= true;
    xmin:= minValue(datos[OX]);
    xmax:= maxValue(datos[OX]);
    ymin:= minValue(datos[OY]);
    ymax:= maxValue(datos[OY]);
    rangox:= xmax-xmin;
    rangoy:= ymax-ymin;

    if (rangox=0) or (rangoy=0) then OK:= False
    else
    begin
    ancho := im.Width;
    alto:= im.Height;

    if borrar then
    begin
      im.Canvas.Brush.Color:= clfondo;
      im.Canvas.clear;
    end;


    im.Canvas.Pen.Color:= clpluma;
    im.Canvas.brush.color:= clrelleno;

    xp:= XPixel(datos[OX, 0]);  //punto inicial
    yp:= YPixel(datos[OY, 0]);  //punto inicial
    im.Canvas.MoveTo(xp, yp);

    for j:=0 to high(datos[0]) do
    begin
     xp:= XPixel(datos[OX, j]);
     Yp:= YPixel(datos[OY, j]);
     im.Canvas.Ellipse(xp-radio, yp-radio, xp+radio, yp+radio);
     if linea then im.Canvas.LineTo(xp, yp);
    end;
    OK:= True
    end;
        if marcarFin then
        begin
             im.Canvas.Pen.Color:= clfin;
             im.Canvas.brush.Color:= clfin;
             im.Canvas.Ellipse(xp-radio, yp-radio, xp+radio, yp+radio)
        end;
    result:= OK;
  end;

//FUNCIONES MOVIMIENTO DE PROTEÍNAS

function traslacion(dx, dy, dz: real; V: TPunto): TPunto;
(*
Función para la traslación de u punto en el espacio
  :Parámetros:
      :param dx, dy, dz: real que indica cuánto se mueve en cada dirección
      :param V: TPunto que vamos a trasladar
  :salida:
      :TPunto: TPunto con las nuevas coordenadas
*)
  begin
  traslacion.X:= V.X + dx;
  traslacion.Y:= V.Y + dy;
  traslacion.Z:= V.Z + dz;
  end;

function traslacion(dx, dy, dz: real; datos: TPuntos): TPuntos; overload;
(*
Función para la traslación de varios puntos a la vez
    :Parámetros:
        :param dx, dy, dz: real que indica cuánto se mueve en cada dirección
        :param datos: Conjunto de puntos que se va a trasladar
    :salida:
        :TPuntos: TPuntos con las nuevas coordenadas
*)
   var
      salida: TPuntos;
      j: integer;
   begin
      setlength(salida, high(datos)+1);
      for j:=0 to high(datos) do
      begin
       salida[j].X := datos[j].X + dx;
       salida[j].Y := datos[j].Y + dy;
       salida[j].Z := datos[j].Z + dz;
      end;
      result:= salida;
   end;

function traslacion(dx, dy, dz: real; var p: TPDB): integer; overload;
(*
Función para la traslación de puntos en un TPDB
    :Parámetros:
        :param dx, dy, dz: real que indica cuánto se mueve en cada dirección
        :param p: TPDB que queremos trasladar:
    :salida:
        :p: El resultado se guarda directamente aquí
        :integer: es un valor que igualamos a 1 para tener una salida y poder
                  usar una función. Sin este valor no podríamos usarla
*)
  var
     j: integer;
  begin
     for j:=1 to p.NumFichas do
     begin
        p.atm[j].coor.x := p.atm[j].coor.x + dx;
        p.atm[j].coor.y := p.atm[j].coor.y + dy;
        p.atm[j].coor.z := p.atm[j].coor.z + dz;
     end;
  result:= 1;
  end;

function GiroOX(rad: real; V: TPunto): TPunto;
(*
Función para la rotación de un punto sobre el eje OX
    :Parámetros:
        :param rad: cantidad que gira en radianes
        :param V: TPunto que se gira
    :salida:
        :TPunto: TPunto con las nuevas coordenadas
*)
  var
     seno, coseno: real;
  begin
     seno:= sin(rad);
     coseno:= cos(rad);

     GiroOX.X:= V.X;
     GiroOX.Y:= V.Y*coseno - V.Z*seno;
     GiroOX.Z:= V.Y*seno + V.Z*coseno;
  end;

function GiroOX(rad: real; datos: TPuntos): TPuntos; overload;
(*
Función para la rotación de conjunto de puntos sobre el eje OX
    :Parámetros:
        :param rad: cantidad que gira en radianes
        :param datos: TPuntos que se giran
    :salida:
        :TPunto: TPunto con las nuevas coordenadas
*)
  var
     s: TPuntos;
     j: integer;
  begin
     setlength(s, high(datos)+1);
     for j:=0 to high(datos) do
     begin
        s[j]:= GiroOX(rad, datos[j]);
     end;
     result := s;
  end;

function GiroOX(rad: real; var p: TPDB): integer; overload;
(*
Función para la rotación de un TPDB sobre el eje OX
    :Parámetros:
        :param rad: cantidad que gira en radianes
        :param p: TPDB que se gira
    :salida:
        :p: El resultado se guarda directamente aquí
        :integer: Forzamos una variable int para poder usar la función
*)
  var
     j:integer;
     seno, coseno: real;
  begin
     for j:=1 to p.NumFichas do
     begin
          seno:= sin(rad);
          coseno:= cos(rad);
          p.atm[j].coor.y := p.atm[j].coor.y*coseno-p.atm[j].coor.z*seno;
          p.atm[j].coor.z := p.atm[j].coor.z*coseno + p.atm[j].coor.y*seno;
     end;
     result:=1;
  end;

function GiroOY(rad: real; V: TPunto): TPunto;
(*
Análogo a GiroOX(). Rotación en el eje Y
*)
  var
     seno, coseno: real;
  begin
     seno:= sin(rad);
     coseno:= cos(rad);

     GiroOY.X:= V.X*coseno + V.Z*seno;
     GiroOY.Y:= V.Y;
     GiroOY.Z:= V.Z*coseno - V.X*seno;
  end;

function GiroOY(rad: real; datos: TPuntos): TPuntos; overload;
(*
Análogo a GiroOX(). Rotación en el eje Y
*)
  var
     s: TPuntos;
     j: integer;
  begin
     setlength(s, high(datos)+1);
     for j:=0 to high(datos) do
     begin
       s[j] := GiroOY(rad, datos[j]);
     end;
     result := s;
  end;

function GiroOY(rad: real; var p: TPDB): integer; overload;
(*
Análogo a GiroOX(). Rotación en el eje Y
*)
  var
     j: integer;
     seno, coseno: real;
  begin
    seno:= sin(rad);
    coseno:= cos(rad);
    for j:=1 to p.NumFichas do
    begin
      p.atm[j].coor.X:= p.atm[j].coor.X*coseno + p.atm[j].coor.Z*seno;
      p.atm[j].coor.Z:= p.atm[j].coor.Z*coseno - p.atm[j].coor.Z*seno;
    end;
    result:= 1;
  end;

function GiroOZ(rad: real; V: TPunto): TPunto;
(*
Análogo a GiroOX(). Rotación en el eje Z
*)
 var
    seno, coseno: real;
 begin
    seno:= sin(rad);
    coseno:= cos(rad);

    GiroOZ.X:= V.X*coseno + V.Y*seno;
    GiroOZ.Y:= V.X*seno + V.Y*coseno;
    GiroOZ.Z:= V.Z;
 end;

function GiroOZ(rad: real; datos: TPuntos): TPuntos; overload;
(*
Análogo a GiroOX(). Rotación en el eje Z
*)
 var
    s: TPuntos;
    j: integer;
 begin
    setlength(s, high(datos)+1);
    for j:=0 to high(datos) do
    begin
      s[j]:= GiroOZ(rad, datos[j]);
    end;
    result := s;
 end;

function GiroOZ(rad: real; var p: TPDB): integer; overload;
(*
Análogo a GiroOX(). Rotación en el eje Z
*)
 var
    j: integer;
    seno, coseno: real;
 begin
   seno:= sin(rad);
   coseno:= cos(rad);
   for j:=1 to p.NumFichas do
   begin
     p.atm[j].coor.X:= p.atm[j].coor.X*coseno - p.atm[j].coor.Y*seno;
     p.atm[j].coor.Y:= p.atm[j].coor.Y*coseno + p.atm[j].coor.X*seno;
   end;
   result:=1;
 end;

 function Alinear_eje_Z(puntos: TPuntos): TPuntos;
 {
 Función para trasladar un conjunto de puntos tal que dos de ellos
 queden alineados en el eje z
 :parámetros:
    :param puntos: Puntos que se van a trasladar
 :salida:
    :TPuntos: puntos ya trasladados
 }
   var
      salida: TPuntos;
      p1, p2: TPunto;
      a, b, c, d1, d2, alfa, phi, senoalfa, senophi: real;
   begin
      setlength(salida, high(puntos)+1);
      p1:= puntos[0];
      salida:= traslacion(-p1.x, -p1.y, -p1.z, puntos);
      p2:= salida[high(salida)];
      a:= p2.X;
      b:= p2.Y;
      c:= p2.Z;
      d1:= sqrt(sqr(b)+ sqr(c));
      d2:= sqrt(sqr(a) + sqr(b)+ sqr(c));
      senoalfa:= a/d2;
      senophi:= b/d1;
      phi:= arcsin(senophi);
      alfa:= arcsin(senoalfa);
      if c<0 then phi:= -phi else alfa:= -alfa;
      salida:= GiroOX(phi, salida);
      salida:= GiroOY(alfa, salida);
      result:= salida;

 end;
end.

