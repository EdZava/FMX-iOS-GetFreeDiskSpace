unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Layouts,
  FMX.ListBox;

type
  TForm1 = class(TForm)
    Log: TMemo;
    Edit1: TEdit;
    Layout1: TLayout;
    btnGetInfo: TButton;
    chkbxFormat: TCheckBox;
    Layout2: TLayout;
    Label1: TLabel;
    lblFileSystemSize: TLabel;
    Label2: TLabel;
    lblFileSystemFreeSize: TLabel;
    ComboBox1: TComboBox;
    procedure btnGetInfoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    List: TStringList;
    procedure AddList(Name, Path: string);
    { Private declarations }
  public
    { Public declarations }
  end;

  { Class helper iOS and OSx }
  TMacHelper = class
  protected
    class function GetFileSytemSizeByKey(sKey: string): Int64;

  public
    class function GetFileSystemSize: Int64;
    class function GetFileSystemFreeSize: Int64;
  end;

  TByptesHelper = class
  public
    class function FormatBytesToStr(Bytes: Int64): string;
  end;

var
  Form1: TForm1;

implementation

uses
  Macapi.ObjectiveC
{$IFDEF IOS}
  , iOSapi.Foundation
{$ELSE}
  , Macapi.Foundation
{$ENDIF IOS}
  , System.Math
  , System.IOUtils;

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  List := TStringList.Create;
  ComboBox1.Items.Clear;

  Self.AddList('/', '/');
  Self.AddList('GetTempPath', TPath.GetTempPath);
  Self.AddList('GetHomePath', TPath.GetHomePath);
  Self.AddList('GetDocumentsPath', TPath.GetDocumentsPath);
  Self.AddList('GetSharedDocumentsPath', TPath.GetSharedDocumentsPath);
  Self.AddList('GetLibraryPath', TPath.GetLibraryPath);
  Self.AddList('GetCachePath', TPath.GetCachePath);
  Self.AddList('GetPublicPath', TPath.GetPublicPath);
  Self.AddList('GetPicturesPath', TPath.GetPicturesPath);
  Self.AddList('GetSharedPicturesPath', TPath.GetSharedPicturesPath);
  Self.AddList('GetCameraPath', TPath.GetCameraPath);
  Self.AddList('GetSharedCameraPath', TPath.GetSharedCameraPath);
  Self.AddList('GetMusicPath', TPath.GetMusicPath);
  Self.AddList('GetSharedMusicPath', TPath.GetSharedMusicPath);
  Self.AddList('GetMoviesPath', TPath.GetMoviesPath);
  Self.AddList('GetSharedMoviesPath', TPath.GetSharedMoviesPath);
  Self.AddList('GetAlarmsPath', TPath.GetAlarmsPath);
  Self.AddList('GetSharedAlarmsPath', TPath.GetSharedAlarmsPath);
  Self.AddList('GetDownloadsPath', TPath.GetDownloadsPath);
  Self.AddList('GetSharedDownloadsPath', TPath.GetSharedDownloadsPath);
  Self.AddList('GetRingtonesPath', TPath.GetRingtonesPath);
  Self.AddList('GetSharedRingtonesPath', TPath.GetSharedRingtonesPath);

  ComboBox1.ItemIndex := 0;
end;

procedure TForm1.AddList(Name, Path: string);
begin
  ComboBox1.Items.Add(Name);
  List.Add(Path);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(List);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Edit1.Text := List[ComboBox1.ItemIndex];
end;

procedure TForm1.btnGetInfoClick(Sender: TObject);
var
  iSize: Int64;
begin
  Log.Lines.Clear;

  iSize := TMacHelper.GetFileSystemSize;
  if chkbxFormat.IsChecked then
     lblFileSystemSize.Text := TByptesHelper.FormatBytesToStr(iSize)
  else
     lblFileSystemSize.Text := iSize.ToString;

  iSize := TMacHelper.GetFileSystemFreeSize;
  if chkbxFormat.IsChecked then
     lblFileSystemFreeSize.Text := TByptesHelper.FormatBytesToStr(iSize)
  else
     lblFileSystemFreeSize.Text := iSize.ToString;
end;

{ TMacHelper }

class function TMacHelper.GetFileSystemFreeSize: Int64;
begin
  Result := Self.GetFileSytemSizeByKey('NSFileSystemFreeSize')
end;

class function TMacHelper.GetFileSystemSize: Int64;
begin
  Result := Self.GetFileSytemSizeByKey('NSFileSystemSize')
end;

class function TMacHelper.GetFileSytemSizeByKey(sKey: string): Int64;
var
  Dict: NSDictionary;
  P: Pointer;
  FolderName: string;
const
  _FolderName = '/';
  _FoundationFwk: string = '/System/Library/Frameworks/Foundation.framework/Foundation'; //unit iOSapi.Foundation;

begin
  Result := 0;

  FolderName := Form1.Edit1.Text;
  Form1.Log.Lines.Add(FolderName);

  Dict := TNSFileManager.Wrap(TNSFileManager.OCClass.defaultManager).attributesOfFileSystemForPath(NSStr(FolderName), nil);
  if Dict = nil then
    Exit;

  P := Dict.objectForKey((CocoaNSStringConst(_FoundationFwk, sKey) as ILocalObject).GetObjectID);
  if Assigned(P) then
    Result := TNSNumber.Wrap(P).unsignedLongLongValue;
end;

{ TByptesHelper }

class function TByptesHelper.FormatBytesToStr(Bytes: Int64): string;
const
  Description: Array [0..8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
  Kilo = 1000;
var
  i: Integer;
  iValue: Extended;

begin
  i := 0;

  while Bytes > Power(Kilo, i + 1) do
    Inc(i);

  Result := FormatFloat('###0.##', Bytes / IntPower(Kilo, i)) + ' ' + Description[i];
end;

end.
