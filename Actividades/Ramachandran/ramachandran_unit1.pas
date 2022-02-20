unit Ramachandran_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, biotoolkit, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ColorDialog1: TColorDialog;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Form1: TForm1;
  datos: TTablaDatos;
  p: TPDB;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  image1.Canvas.clear;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
    Halt;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if opendialog1.execute then
  begin
    memo1.clear;
    memo1.lines.loadfromfile(opendialog1.FileName);
    edit1.Text:= extractFileName(opendialog1.FileName);
    p:= CargarPDB(memo1.Lines);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  pluma, relleno, fondo: TColor;
  j, k: integer;
begin
  pluma:= Shape1.brush.color;
  relleno:= Shape2.brush.color;
  fondo:= Shape3.brush.color;
  memo2.clear;
  edit2.text:='RESIDUO';
  edit3.text:='PHI';
  edit4.text:='PSI';
  for j:=1 to p.NumSubunidades do
  begin
    setlength(datos, 2, p.sub[j].resN - p.sub[j].res1 - 1);
    memo2.visible:=false;
    for k:= p.sub[j].res1+1 to p.sub[j].resn-1 do
    begin
        datos[0, k - p.sub[j].res1-1]:=  p.res[k].phi;
        datos[1, k - p.sub[j].res1-1]:= p.res[k].psi;
        memo2.Lines.add(padright(p.res[k].ID3 + inttostr(p.res[k].NumRes) + p.res[k].subunidad, 10) +
                        padleft(formatfloat('0.00', p.res[k].phi*180/pi),10) +
                        padleft(formatfloat('0.00', p.res[k].psi*180/pi),10));
    end;
    memo2.visible:= True;
    plotXY(datos, Image1, 0, 1, false, false, pluma, relleno, fondo)
  end;
end;

procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ColorDialog1.Execute then Shape1.Brush.Color:= ColorDialog1.color;
end;

procedure TForm1.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ColorDialog1.Execute then Shape2.Brush.Color:= ColorDialog1.color;
end;

procedure TForm1.Shape3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ColorDialog1.Execute then Shape3.Brush.Color:= ColorDialog1.color;
end;

end.

