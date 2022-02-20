unit extraer_Ca_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, biotoolkit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  p: TPDB;
  texto: TStrings;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if opendialog1.execute then
  begin
    memo1.clear;
    memo1.lines.loadfromfile(opendialog1.FileName);
    edit1.Caption:= opendialog1.Filename;
    p:= CargarPDB(memo1.Lines);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  j: integer;
begin
  Memo2.visible:= False;
  for j:=0 to p.NumFichas do
    begin
      if p.atm[j].ID = 'CA' then memo2.Lines.add(writePDB(p.atm[j]));
    end;
  Memo2.visible:= True;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if savedialog1.execute then memo2.lines.savetofile(savedialog1.filename);
end;



end.

