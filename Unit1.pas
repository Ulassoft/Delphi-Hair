unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Types3D,
  System.Math.Vectors, FMX.Ani, FMX.Controls3D, FMX.Viewport3D, FMX.Objects3D,
  FMX.MaterialSources;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    Light1: TLight;
    FloatAnimation1: TFloatAnimation;
    Cube1: TCube;
    Cylinder1: TCylinder;
    Cone1: TCone;
    Sphere1: TSphere;
    LightMaterialSource1: TLightMaterialSource;
    LightMaterialSource2: TLightMaterialSource;
    LightMaterialSource3: TLightMaterialSource;
    procedure FloatAnimation1Process(Sender: TObject);
    procedure Cube1Render(Sender: TObject; Context: TContext3D);
    procedure Cylinder1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single; RayPos, RayDir: TVector3D);
    procedure Cylinder1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
    procedure Sphere1Render(Sender: TObject; Context: TContext3D);
    procedure FormCreate(Sender: TObject);
  private
    procedure SetDeltaMove(const Value: TPoint3D);
    function GetDeltaMove: TPoint3D;
    { Private declarations }
  public
    { Public declarations }
    AndroidButton:Boolean;
    MoveStart,MoveEnd :TPoint3D;
    property DeltaMove:TPoint3D read GetDeltaMove write SetDeltaMove;


  end;

var
  Form1: TForm1;

implementation

Uses System.Math;

{$R *.fmx}

procedure TForm1.Cube1Render(Sender: TObject; Context: TContext3D);
var
S:TCube;
L:Single;
D,N,M:TPoint3D;
begin
if Not(Sender is TCube) Then Exit;
if Not Assigned(TCube(Sender)) Then Exit;

S:=TCube(Sender);
L:=TCube(S.Parent).Width * 0.5 +S.Width* 0.5;



D:=S.RotationCenter.Point-(DeltaMove*S.TagFloat);
N:=D.Normalize*L;


M:=Sphere1.AbsoluteToLocal3D(S.LocalToAbsolute3D(N));
if  M.Length>(Sphere1.Width*0.5)
then S.Position.Point:=N
else S.Position.Point:=S.RotationCenter.Point*L;

//S.Position.Point:=N;
//S.Position.Point:=S.RotationCenter.Point*L;

end;

procedure TForm1.Cylinder1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single; RayPos, RayDir: TVector3D);
begin
if ssLeft in Shift
	then With Cylinder1
		do begin
			if Not AndroidButton
				then begin
					RotationCenter.Point:=Position.Point-RayPos.Length*(RayDir *Point3D(1,1,0));
					AndroidButton:=True;
          DeltaMove:=RayPos.Length*RayDir;
				end;
				Position.Point:=RotationCenter.Point+RayPos.Length*(RayDir *Point3D(1,1,0));
        DeltaMove:=RayPos.Length*RayDir;
		end;
end;

procedure TForm1.Cylinder1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
begin
AndroidButton:=False;
DeltaMove:=MoveEnd;
end;

procedure TForm1.FloatAnimation1Process(Sender: TObject);
begin
if AndroidButton then DeltaMove:=MoveEnd;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
A,B :Integer;
S,C:TCube;
P:TPoint3D;
K,G,D:Single;
M:Integer;
begin
Cylinder1.AutoCapture:=True;

M:=24;
D:=c2PI/M;
G:=cPIdiv2;
for A:=1 to M
	do begin
		P:=Point3D(Cos(G),-1,Sin(G)).Normalize;
		G:=G+D;
		K:=0;
		C:=Nil;
		S:=TCube(Cube1.Clone(Nil));
		S.OnRender:=Cube1Render;
		S.RotationCenter.Point:=P.Normalize;
		S.TagFloat:=0;
		Sphere1.AddObject(S);
		c:=S;
		S:=Nil;
		if Sin(G)>-0.4
			then begin
				for B:=1 to 15
				do begin
				K:=K+(1/8);
				S:=TCube(Cube1.Clone(Nil));
				S.OnRender:=Cube1Render;
				P:=P+Point3D(0,P.Length,0);
				S.RotationCenter.Point:=P.Normalize;
				S.TagFloat:=K;
				C.AddObject(S);
				C:=S;
				S:=Nil;

			end;
		end;
  end;
Cube1.Visible:=False;




end;



function TForm1.GetDeltaMove: TPoint3D;
begin
    Result:=(MoveStart-MoveEnd)*10;
end;



procedure TForm1.SetDeltaMove(const Value: TPoint3D);
begin
  MoveEnd:=MoveStart;
  MoveStart:=Value;
end;

procedure TForm1.Sphere1Render(Sender: TObject; Context: TContext3D);
var
R:TPOint3D;
begin
R:=Context.CurrentCameraInvMatrix.M[3]-Sphere1.AbsolutePosition;
R:=R.Normalize;
Sphere1.ResetRotationAngle;
Sphere1.RotationAngle.Y:=(ArcTan2(R.X,R.Z)+cPI)*c180divPI;
Sphere1.RotationAngle.X:=ArcSin(R.y)*c180divPI;
//

end;

end.
