unit discriminar_formatos_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, biotoolkit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  formato: string;
  texto: TStrings;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.execute then
  begin
    memo1.clear;
    memo1.lines.loadfromfile(OpenDialog1.filename);
    edit1.Caption:= OpenDialog1.Filename;
    texto:= memo1.Lines
  end;

  formato:= 'Formato no soportado'; //valor predeterminado

  //cambiar formato según las reglas establecidas
  if (copy(texto[0],0,1)='>')then formato:= 'FASTA';
  if (copy(texto[0],0,6)= 'HEADER') then formato:= 'PDB';
  if (copy(texto[0],0,2)='ID') and (copy(texto[1],0,2)='XX')
   then formato:= 'EMBL';
  if (copy(texto[0],0,2)='ID') and (copy(texto[1],0,2)='AC')
   then formato:= 'UniProt';
  if (copy(texto[0],0,5)='LOCUS')
   then formato:= 'GenBank';

   Label2.Caption:= formato;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  memo2.lines.clear;
  memo2.lines.add(extraerSecuencia(texto, formato));
end;


end.

