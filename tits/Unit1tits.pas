unit Unit1tits;  // снипеты из файлов, однострочные
{
1.1.24 какимто хуем прога стала понимать русс буквы. в оригпнале не понимала, ав в форке понимает.
эффектом этого €вилось пустые буквы. перелопатив этот акал пофиксил это. надолголи хз.
предчуствую завтра снова перевернетс€. и придетс€ начинать с нначала. поэтому ос
тавл€ю эту заметку дл€ теб€.

}

interface

uses   ClipBrd,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure kass(Sender: TObject);
    procedure here(Sender: TObject);
  end;

var
  Form1: TForm1;
  root: string; // путь к файлам снипов
  b: tstringlist;  // список файлов
  a: array of tmenuitem; // главные пункты
  c: array of array of tmenuitem; // подпункты
  s: array of tstringlist; // файлы считаны сюда
  hr: tmenuitem;   // пункт here


   WS: WideString;
type UTF8String = type string;
implementation

{$R *.dfm}

 function UnicodeToUtf8(Dest: PChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Cardinal;
begin
  Result := 0;
  if Source = nil then Exit;
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceChars) and (count < MaxDestBytes) do
    begin
      c := Cardinal(Source[i]);
      Inc(i);
      if c <= $7F then
      begin
        Dest[count] := Char(c);
        Inc(count);
      end
      else if c > $7FF then
      begin
        if count + 3 > MaxDestBytes then
          break;
        Dest[count] := Char($E0 or (c shr 12));
        Dest[count+1] := Char($80 or ((c shr 6) and $3F));
        Dest[count+2] := Char($80 or (c and $3F));
        Inc(count,3);
      end
      else //  $7F < Source[i] <= $7FF
      begin
        if count + 2 > MaxDestBytes then
          break;
        Dest[count] := Char($C0 or (c shr 6));
        Dest[count+1] := Char($80 or (c and $3F));
        Inc(count,2);
      end;
    end;
    if count >= MaxDestBytes then count := MaxDestBytes-1;
    Dest[count] := #0;
  end
  else
  begin
    while i < SourceChars do
    begin
      c := Integer(Source[i]);
      Inc(i);
      if c > $7F then
      begin
        if c > $7FF then
          Inc(count);
        Inc(count);
      end;
      Inc(count);
    end;
  end;
  Result := count+1;  // convert zero based index to byte count
end;


function Utf8Encode(const WS: WideString): UTF8String;
var
  L: Integer;
  Temp: UTF8String;
begin
  Result := '';
  if WS = '' then Exit;
  SetLength(Temp, Length(WS) * 3); // SetLength includes space for null terminator

  L := UnicodeToUtf8(PChar(Temp), Length(Temp)+1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;

function AnsiToUtf8(const S: string): UTF8String;
begin
  Result := Utf8Encode(S);
end;

function utf8to(x: string): string;// utf8  --->  cp1251
var i: cardinal;
    d: string;
    w: word;
    a: array[0..1]of char absolute w;
begin
d:='';
i:=1;//
while i<=length(x) do begin
  case x[i] of
    #0..#$80: d:=d+x[i];
    #$d0,#$d1: begin
      a[1]:=x[i];
      inc(i);
      a[0]:=x[i];
      case w of
        $D0B0..$D0BF: d:=d+chr(w-$D0B0+$e0);
        $D180..$D18F: d:=d+chr(w-$D180+$f0);
        $D090..$D09F: d:=d+chr(w-$D090+$c0);
        $D0A0..$D0AF: d:=d+chr(w-$D0A0+$d0);
        else d:=d+'?';
        end;
      end;
      else d:=d+x[i]; // мудила
    end; // case x[i]
  inc(i);
  end;
result:=d;  
end;
//*****************************************

function NameNoExt(x: string): string;
begin // им€ файла без расширени€
 result:=Copy(x,1,length(x)-length(ExtractFileExt(x)));
end;


function getlist2(src,msk: string; x: tstringlist): word; // список файлов по маске
var i: integer;
    sr: TSearchRec;
    FileAttrs: Integer;
    zz: tstringlist;


    procedure addy;
    begin
      inc(i);
      zz.add(sr.Name);
    end;
begin
  zz:=tstringlist.create;
  FileAttrs:=0
     +faHidden   // скрытый
     +faSysFile  // системный
     +faVolumeID //
     +faArchive  // архивный
     +faAnyFile; // любой

  i:=0;
  if FindFirst((src+msk), FileAttrs, sr)=0 then   //
    if (sr.Attr and FileAttrs)=sr.Attr then
      begin
        addy;
        while FindNext(sr)=0 do
          if (sr.Attr and FileAttrs)=sr.Attr then
            addy;
        FindClose(sr);
      end;
  result:=i;
  zz.Sort;
  x.assign(zz);
  zz.free;
end;



procedure TForm1.FormCreate(Sender: TObject);
var i,j,n: integer;   z: string;
begin
  root:=extractfilepath(paramstr(0));   // с слешем
  n:=getlist2(root,'*.txt',b);
  memo1.Lines.Assign(b);
  //**********
  setlength(s,n);
  for i:=0 to high(s) do s[i]:=tstringlist.Create();
  for i:=0 to n-1 do
    s[i].loadfromfile(root+b[i]);

  setlength(a,n);
  setlength(c,n);
  for i:=0 to high(a) do
    begin
      a[i]:=NewLine;
      a[i].Caption:=NameNoExt(b[i]);
      mainmenu1.items.insert(mainmenu1.items.count,a[i]);
    end;

  z:='+';
  z:='';
  for i:=0 to high(a) do
    begin
      setlength(c[i],s[i].count div 2);
      for j:=0 to high(c[i]) do
        begin
          c[i][j]:=TmenuItem.Create(a[i]);  //
          c[i][j].Caption:=z+utf8to(s[i][2*j])+z;

          c[i][j].Tag:=i*10000+j*2+1;
          a[i].insert(a[i].count,c[i][j]);  //
          c[i][j].OnClick:=kass;
        end;
    end;

//*******************
   hr:= NewLine;
   hr.Caption:='here';
   hr.OnClick:=here;
   mainmenu1.items.insert(mainmenu1.items.count,hr);
end;


procedure CopyStringToClipboard(const Value: String); // буфер дл€ русских  uses ClipBrd,
const
  RusLocale = (SUBLANG_DEFAULT shl $A) or LANG_RUSSIAN;
var
  hMem: THandle;
  pData: Pointer;
begin
  Clipboard.AsText:=value;  // разблокировать буфер. хз как он блокирутс€, почему однозар€дный
  Clipboard.Open;
  try
    Clipboard.AsText := Value;
    hMem := GlobalAlloc(GMEM_MOVEABLE, SizeOf(DWORD));
    try
      pData := GlobalLock(hMem);
      try
        DWORD(pData^) := RusLocale;
      finally
        GlobalUnlock(hMem);
      end;
        Clipboard.SetAsHandle(CF_LOCALE, hMem);
    finally
      GlobalFree(hMem);
    end;
  finally
    Clipboard.Close;
  end;
end;


procedure TForm1.kass(Sender: TObject);
var i,j,k: integer; d: string;
begin
  k:=(sender as tmenuitem).Tag;
  i:=k div 10000;
  j:=k mod 10000;
  d:=utf8to(s[i][j]);
  CopyStringToClipboard(d);
  memo1.Lines.text:=d;
end;

procedure TForm1.here(Sender: TObject);
begin
  memo1.Lines.text:=paramstr(0);
end;


initialization
  b:=TStringList.Create();
finalization
  b.Free;
end.

