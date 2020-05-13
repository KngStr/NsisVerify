unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

type
  TfrmNsisVerify = class(TForm)
    btnDo: TButton;
    mmo1: TMemo;
    OpenDialog1: TOpenDialog;
    procedure btnDoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  (*
    #define FH_FLAGS_MASK 15
    #define FH_FLAGS_UNINSTALL 1
    #ifdef NSIS_CONFIG_SILENT_SUPPORT
    #  define FH_FLAGS_SILENT 2
    #endif
    #ifdef NSIS_CONFIG_CRC_SUPPORT
    #  define FH_FLAGS_NO_CRC 4
    #  define FH_FLAGS_FORCE_CRC 8
    #endif

    #define FH_SIG 0xDEADBEEF

    // neato surprise signature that goes in firstheader. :)
    #define FH_INT1 0x6C6C754E
    #define FH_INT2 0x74666F73
    #define FH_INT3 0x74736E49

    typedef struct
    {
      int flags; // FH_FLAGS_*
      int siginfo;  // FH_SIG

      int nsinst[3]; // FH_INT1,FH_INT2,FH_INT3

      // these point to the header+sections+entries+stringtable in the datablock
      int length_of_header;

      // this specifies the length of all the data (including the firstheader and CRC)
      int length_of_all_following_data;
    } firstheader;
  *)

  TNsisHeader = packed record
    flags: Integer;
    siginfo: Integer;
    nsinst: array[0..11] of AnsiChar; //array[0..2] of Integer;
    length_of_header: Integer;
    length_of_all_following_data: Integer;
  end;

const
  FH_SIG: Integer = $DEADBEEF;

  // neato surprise signature that goes in firstheader. :)
  FH_INT1: Integer = $6C6C754E;
  FH_INT2: Integer = $74666F73;
  FH_INT3: Integer = $74736E49;

var
  frmNsisVerify: TfrmNsisVerify;

implementation

{$R *.dfm}

uses
  IdHashCRC;

function GetCRC(const AStream: TStream; const AStartPos, ASize: Int64): String;
var
  crc: TIdHashCRC32;
begin
  crc := TIdHashCRC32.Create;
  try
    Result := crc.HashStreamAsHex(AStream, AStartPos, ASize);
  finally
    crc.Free;
  end;
end;

procedure TfrmNsisVerify.btnDoClick(Sender: TObject);
var
  F: TFileStream;
  H: TNsisHeader;
  LCrc: Integer;
  LPos: Integer;
  Crc: string;
  I: Integer;
begin
  if not OpenDialog1.Execute(Handle) then
    Exit;

  F := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
  try
    for I := 0 to F.Size div 512 do begin
      F.Seek(I * 512, soBeginning);
      F.Read(H, SizeOf(H));

      if (H.siginfo = FH_SIG) and (AnsiString(H.nsinst) = 'NullsoftInst') then
        Break;
    end;

    if AnsiString(H.nsinst) <> 'NullsoftInst' then begin
      mmo1.Lines.Add('未发现文件头，可能不是NSIS文件');
      Exit;
    end;

    LPos := I * 512;
    mmo1.Lines.Add('');
    mmo1.Lines.Add(Format('Header Position: %x', [LPos]));
    mmo1.Lines.Add(Format('Label: %s', [string(AnsiString(H.nsinst))]));
    mmo1.Lines.Add(Format('Header Size: %x', [H.length_of_header]));
    mmo1.Lines.Add(Format('Data Size: %x', [H.length_of_all_following_data]));
    mmo1.Lines.Add('');

    //读取CRC
    F.Seek(LPos + H.length_of_all_following_data - 4, soBeginning);
    mmo1.Lines.Add(Format('CRC Position: %x', [F.Position]));
    F.Read(LCrc, SizeOf(LCrc));
    mmo1.Lines.Add(Format('LCrc: %x', [LCrc]));

    //计算CRC
    F.Seek(0, soBeginning);
    Crc := GetCRC(F, $200, LPos + H.length_of_all_following_data - 4 - $200);
    mmo1.Lines.Add(Format('Crc: %s size:%x', [Crc, LPos + H.length_of_all_following_data - 4 - $200]));

    if StrToIntDef('$' + Crc, -1) = LCrc then
      mmo1.Lines.Add('校验成功')
    else
      mmo1.Lines.Add('校验失败');
  finally
    FreeAndNil(F);
  end;
end;

end.
