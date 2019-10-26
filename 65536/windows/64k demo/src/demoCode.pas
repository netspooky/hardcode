unit demoCode;


interface

Uses OpenGL, Windows, Textures;

var ElapsedTime : Integer;
    base : glUint;                // base to the font display lists

  procedure initData;
  procedure drawDemo;


implementation

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

const // Blob Constants
      xRows =48;
      yRows =16;
      numVertices = 2*yrows*xrows+xrows+2;   //842;
      numTriangles = 2*xrows+yrows*xrows*4;  //1680;

const TUNNEL_SPEED = 1/50;
      PI_8 = 0.3926990816987;    // PI/8

type TNormal = record
       X, Y, Z : glFloat;             // X, Y, Z coordinates
     end;
     TVertex = record
       X, Y, Z : glFloat;             // X, Y, Z coordinates
     end;
     TTexCoord = record
       U, V : glFloat;                // U and V Texture coordinates
     end;
     TTriangle = record
       V : Array[0..2] of Integer;     // Vertices
       T : Array[0..2] of TTexCoord;   // Texture coordinates
       n : TNormal;                    // Triangle normal
     end;
     TBlob = Record
       vertex : Array[0..numVertices-1] of TVertex;
       Triangle : Array[0..numTriangles-1] of TTriangle;
     end;

//--- Textures  ---//
var ColorsTex : glUint;
    BlueTex   : glUint;

//--- User variables ---//
var Blob : TBlob;
    Sphere : TBlob;
    LU : Array[0..numVertices-1] of TVertex;   // blob lookup tables
    Tunnels : Array[0..64, 0..32] of TVertex;
    CubeDL : glUint;


{------------------------------------------------------------------}
{  Function to do an arctan                                        }
{------------------------------------------------------------------}
function ArcTan(X, Y : glFloat) : glFloat;
asm
  FLD     Y
  FLD     X
  FPATAN
  FWAIT
end;


procedure glWrite(X, Y : GLUint; text : PChar);
var drawRect : TRect;
begin
  glPushAttrib(GL_DEPTH_TEST);  // Save the current Depth test settings (Used for blending )
  glDisable(GL_DEPTH_TEST);     // Turn off depth testing (otherwise we get no FPS)
  glDisable(GL_TEXTURE_2D);     // Turn off textures, don't want our text textured
  glMatrixMode(GL_PROJECTION);  // Switch to the projection matrix
  glPushMatrix();               // Save current projection matrix
  glLoadIdentity();

  GetWindowRect(GetDesktopWindow(), drawRect);  // Get current window size
  glOrtho(0, drawRect.right, 0, drawRect.bottom, -1, 1);  // Change the projection matrix using an orthgraphic projection
  glMatrixMode(GL_MODELVIEW);  // Return to the modelview matrix
  glPushMatrix();              // Save the current modelview matrix
  glLoadIdentity();
  glColor3f(1.0, 1.0, 1.0);    // Text color

  glRasterPos2i(X, Y);                                // Position the Text
  glPushAttrib(GL_LIST_BIT);                          // Save's the current base list
  glListBase(base - 32);                              // Set the base list to our character list
  glCallLists(length(text), GL_UNSIGNED_BYTE, PChar(text));  // Display the text
  glPopAttrib();                                      // Restore the old base list

  glMatrixMode(GL_PROJECTION);  //Switch to projection matrix
  glPopMatrix();                // Restore the old projection matrix
  glMatrixMode(GL_MODELVIEW);   // Return to modelview matrix
  glPopMatrix();                // Restore old modelview matrix
  glEnable(GL_TEXTURE_2D);      // Turn on textures, don't want our text textured
  glPopAttrib();                // Restore depth testing
end;


{------------------------------------------------------------------}
{  Function to normalize a vector                                  }
{------------------------------------------------------------------}
procedure Normalize(var vector : TNormal);
var length : glFLoat;
begin
  // Calculates The Length Of The Vector
  length := sqrt((vector.X*vector.X) + (vector.Y*vector.Y) + (vector.Z*vector.Z));
  if Length = 0 then
    Length :=1;

  vector.X :=vector.X / length;
  vector.Y :=vector.Y / length;
  vector.Z :=vector.Z / length;
end;


{------------------------------------------------------------------}
{  Function to calculate the normal given 2 vectors (3 vertices)   }
{------------------------------------------------------------------}
function calcNormal(const v : Array of TVertex) : TNormal;
var a, b : TVertex;
begin
  // Calculate The Vector From Point 1 To Point 0
  a.X := V[0].X - V[1].X;
  a.Y := V[0].Y - V[1].Y;
  a.Z := V[0].Z - V[1].Z;
  // Calculate The Vector From Point 2 To Point 1
  b.X := V[1].X - V[2].X;
  b.Y := V[1].Y - V[2].Y;
  b.Z := V[1].Z - V[2].Z;
  // Compute The Cross Product To Give Us A Surface Normal
  result.X := a.Y*b.Z - a.Z*b.Y;      	// Cross Product For Y - Z
  result.Y := a.Z*b.X - a.X*b.Z;      	// Cross Product For Z - X
  result.Z := a.X*b.Y - a.Y*b.X;      	// Cross Product For X - Y

  Normalize(result);	 			// Normalize The Vectors
end;


{------------------------------------------------------------------}
{  Function to create a sphere                                     }
{------------------------------------------------------------------}
procedure CreateSphere(var obj : TBlob);
const R = 10;
      yRing =yRows*4 + 4;
      uTex = 3.0 / (xRows);
      vTex = 3.0 / (3+2*yRows);
var X, Y, I, J : Integer;
    yLevel, Radius : glFloat;
    offset : Integer;
begin
  // Top center
  obj.vertex[0].x := 0;
  obj.vertex[0].z := 0;
  obj.vertex[0].y := -r;
  offset := 1;

  // Top half and center
  for Y :=0 to yRows do
  begin
    yLevel := -r*cos(2*pi*(y+1) / yring);
    radius := r*sin(2*pi*(y+1) / yring);

    for X :=0 to xRows-1 do
    begin
      obj.vertex[offset].x := radius * sin(2*pi*x / xRows);
      obj.vertex[offset].z := radius * cos(2*pi*x / xRows);
      obj.vertex[offset].y := yLevel;
      Inc(offset);
    end;
  end;

  // Bottom half
  for Y :=0 to yRows-1 do
  begin
    yLevel := r*sin(2*pi*(y+1) / yring);
    radius := r*cos(2*pi*(y+1) / yring);

    for X :=0 to xRows-1 do
    begin
      obj.vertex[offset].x := radius * sin(2*pi*x / xRows);
      obj.vertex[offset].z := radius * cos(2*pi*x / xRows);
      obj.vertex[offset].y := ylevel;
      Inc(offset);
    end;
  end;

  // Bottom center
  obj.vertex[offset].x := 0;
  obj.vertex[offset].z := 0;
  obj.vertex[offset].y := r;

  with Obj do
  begin
    for i :=0 to xRows-1 do
    begin
      Triangle[i].v[0] := 0;
      Triangle[i].v[1] := (i+1) MOD xRows +1;
      Triangle[i].v[2] := (i+1);

      Triangle[i].T[0].u := 0.5;
      Triangle[i].T[0].v := 0.0;
      Triangle[i].T[1].u := (i+1)*uTex;
      Triangle[i].T[1].v := vTex;
      Triangle[i].T[2].u := i*uTex;
      Triangle[i].T[2].v := vTex;
    end;

    for J :=0 to yRows*2 -1 do
    begin
      for I :=0 to xRows-1 do
      begin
        offset := xRows+(i+j*xRows)*2;
        Triangle[offset].v[0] := j*xRows+1 + i;
        Triangle[offset].v[1] := j*xRows+1 + (i+1) MOD xRows;
        Triangle[offset].v[2] := j*xRows+1 + i +xRows;

        Triangle[offset].T[0].u := i*uTex;
        Triangle[offset].T[0].v := (1+j) * vTex;
        Triangle[offset].T[1].u := (1+i) * uTex;
        Triangle[offset].T[1].v := (1+j) * vTex;
        Triangle[offset].T[2].u := i     * uTex;
        Triangle[offset].T[2].v := (2+j) * vTex;

        offset := xRows+(i+j*xRows)*2 + 1;
        Triangle[offset].v[0] := j*xRows+1+ (i+1) MOD xRows;
        Triangle[offset].v[1] := j*xRows+1+ (i+1) MOD xRows + xRows;
        Triangle[offset].v[2] := j*xRows+1+   i+xRows;

        Triangle[offset].T[0].u := (i+1) * uTex;
        Triangle[offset].T[0].v := (1+j) * vTex;
        Triangle[offset].T[1].u := (i+1) * uTex;
        Triangle[offset].T[1].v := (2+j) * vTex;
        Triangle[offset].T[2].u := i     * uTex;
        Triangle[offset].T[2].v := (2+j) * vTex;
      end;

      for i := 0 to xRows-1 do
      begin
        offset := xRows+xRows*2*yRows*2 + i;
        Triangle[offset].v[0] := 2*yRows*xRows+1+i;
        Triangle[offset].v[1] := 2*yRows*xRows+1+ (i+1) MOD xRows;
        Triangle[offset].v[2] := 2*yRows*xRows+1+xRows;

        Triangle[offset].T[0].u := i           * uTex;
        Triangle[offset].T[0].v := (yRows*2+1) * vTex;
        Triangle[offset].T[1].u := (i+1)       * uTex;
        Triangle[offset].T[1].v := (yRows*2+1) * vTex;
        Triangle[offset].T[2].u := 0.5;
        Triangle[offset].T[2].v := 1.0;
      end;
    end;
  end;

  // Calculate Normals
  for i :=0 to numTriangles-1 do
    obj.triangle[i].n :=calcNormal([Obj.Vertex[Obj.Triangle[i].V[0]], Obj.Vertex[Obj.Triangle[i].V[1]], Obj.Vertex[Obj.Triangle[i].V[2]]]);
end;


{------------------------------------------------------------------}
{  Function to draw the blob (warped sphere)                       }
{------------------------------------------------------------------}
procedure RenderBlob(const obj : TBlob);
var I : Integer;
begin
  glBindTexture (GL_TEXTURE_2D, ColorsTex);
  glBegin (GL_TRIANGLES);
    begin
      for I :=0 to numTriangles-1 do
      begin
        with obj.Triangle[i] do
        begin
          glTexCoord2f(T[0].u, T[0].v);
          glVertex3f(obj.vertex[v[0]].x, obj.vertex[v[0]].y, obj.vertex[v[0]].z);

          glTexCoord2f (T[1].u, T[1].v);
          glVertex3f (obj.vertex[v[1]].x, obj.vertex[v[1]].y, obj.vertex[v[1]].z);

          glTexCoord2f (T[2].u, T[2].v);
          glVertex3f (obj.vertex[v[2]].x, obj.vertex[v[2]].y, obj.vertex[v[2]].z);
        end;
      end;
    end;
  glEnd();
end;


{------------------------------------------------------------------}
{  Draw the bouncing blob                                          }
{------------------------------------------------------------------}
procedure drawBlob;
var DemoTime : Integer;
    X, Y, C : glFloat;
    I : Integer;
begin
  DemoTime :=ElapsedTime - 4000;

  // --- Drawing the Blob and Rectangle --- //
  glDisable(GL_BLEND);
  glEnable(GL_DEPTH_TEST);
  glColor3f(1.0, 1.0, 1.0);

  // bring in BLob
  if DemoTime < 16900 then
  begin
    X :=DemoTime/250;
    if X > 2 then X :=2;
    glScale(X, X, 1);
  end
  else    // fly away blob
  begin
    X :=(18000 - DemoTime)/500;
    glScale(X, X, 1);
  end;

  glTranslate(0, 0, -2);

  // Rectangle (blob frame)
  glDisable(GL_TEXTURE_2D);
  glLineWidth(3);
  glBegin(GL_LINE_LOOP);
    glVertex3f(-0.32, -0.28, 0.0);
    glVertex3f( 0.32, -0.28, 0.0);
    glVertex3f( 0.32,  0.28, 0.0);
    glVertex3f(-0.32,  0.28, 0.0);
  glEnd;
  glEnable(GL_TEXTURE_2D);

  // Blob
  if (DemoTime > 2800) AND (DemoTime < 10400) OR
     (DemoTime > 10800) AND (DemoTime < 17000) then
    glTranslate(0, 0, abs(0.7*sin(DemoTime/400*pi)));

  glRotate(DemoTime/20, 0, 1, 0);
  glRotate(DemoTime/10, 0, 0, 1);
  C :=DemoTime/1000;

  for i := 0 to numVertices-1 do
  begin
    Y := 1 + 0.1*((1 - cos(LU[i].X + C*5)) +
                  (1 - cos(LU[i].Y + C*7)) +
                  (1 - cos(LU[i].Z + C*8)));
    blob.vertex[i].x := sphere.vertex[i].x * Y;
    blob.vertex[i].y := sphere.vertex[i].y * Y;
    blob.vertex[i].z := sphere.vertex[i].z * Y;
  end;

  glPushMatrix();
    glScale(0.015, 0.015, 0.015);
    glRotate(-DemoTime/50, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, ColorsTex);
    renderBlob(blob);
  glPopMatrix();
end;


{------------------------------------------------------------------}
{  Draw a tentacle                                                 }
{------------------------------------------------------------------}
procedure DrawTentacle(const Step : Integer; const Angle, TwistAngle : glFloat);
begin
  if Step = 19 then exit;

  glTranslate(2.25, 0, 0);

  glRotatef(Angle, 0, 1, 0);
  glRotatef(TwistAngle, 1, 0, 0);

  glCallList(CubeDL);

  glScale(0.9, 0.9, 0.9);
  DrawTentacle(Step+1, Angle, TwistAngle);
end;


{------------------------------------------------------------------}
{  Draw the entire tentacle object                                 }
{------------------------------------------------------------------}
procedure DrawObject(const DemoTime : Integer);
var Angle, TwistAngle : glFloat;
begin
  glCallList(CubeDL);
  glScale(0.9, 0.9, 0.9);

  Angle :=25*sin(DemoTime/600);
  TwistAngle :=25*sin(DemoTime/800);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*cos(DemoTime/500);
  TwistAngle :=25*sin(DemoTime/800);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, -TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/500);
  TwistAngle :=25*cos(DemoTime/600);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/600);
  TwistAngle :=25*sin(DemoTime/400);
  glRotate(90, 0, 1, 0);
  glPushMatrix();
    DrawTentacle(0, Angle, -TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/600);
  TwistAngle :=25*cos(DemoTime/400);
  glRotate(90, 0, 0, 1);
  glPushMatrix();
    DrawTentacle(0, Angle, TwistAngle);
  glPopMatrix();

  Angle :=25*sin(DemoTime/400);
  TwistAngle :=25*cos(DemoTime/800);
  glRotate(180, 0, 0, 1);
  glPushMatrix();
    DrawTentacle(0, -Angle, -TwistAngle);
  glPopMatrix();
end;


{------------------------------------------------------------------}
{  Draw the tentacle scene                                         }
{------------------------------------------------------------------}
procedure drawTentacles;
var X : glFloat;
    DemoTime : Integer;
begin
  DemoTime :=ElapsedTime - 22000;

  glTranslate(0, -0.05, -3);

  X :=DemoTime/10000;
  if X > 0.1 then X :=0.1;
  glScale(X, X, X);

  // Rectangle (blob frame)
  glDisable(GL_TEXTURE_2D);
  glLineWidth(3);
  glBegin(GL_LINE_LOOP);
    glVertex3f(-9, -9, 0.0);
    glVertex3f( 9, -9, 0.0);
    glVertex3f( 9,  9, 0.0);
    glVertex3f(-9,  9, 0.0);
  glEnd;
  glEnable(GL_TEXTURE_2D);

  // Draw the blue tentacles
  glPushMatrix();

    // wobly movement
    if ELapsedTime > 29200 then
      glTranslate(4*cos(ElapsedTime/200), 3*cos(ElapsedTime/230), 0);

    glRotatef(DemoTime/10, 1, 0, 0);
    glRotatef(DemoTime/15, 0, 1, 0);

    glBindTexture(GL_TEXTURE_2D, colorsTex);  // Bind the Texture to the object
    DrawObject(DemoTime);
  glPopMatrix;
end;


procedure ShowScroller;
var DemoTime : Integer;
    X, Y, C : glFloat;
    T, I : Integer;
begin
  DemoTime :=ElapsedTime - 44000;

  // --- Drawing the Blob and Rectangle --- //
  glPushMatrix();
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glColor3f(1.0, 1.0, 1.0);

    glScale(2, 2, 1);
    glTranslate(0, 0, -2);

    // Rectangle (blob frame)
    glDisable(GL_TEXTURE_2D);
    glLineWidth(3);
    glBegin(GL_LINE_LOOP);
      glVertex3f(-0.32, -0.28, 0.0);
      glVertex3f( 0.32, -0.28, 0.0);
      glVertex3f( 0.32,  0.28, 0.0);
      glVertex3f(-0.32,  0.28, 0.0);
    glEnd;
    glEnable(GL_TEXTURE_2D);

    // Blob
    glRotate(DemoTime/20, 0, 1, 0);
    glRotate(DemoTime/10, 0, 0, 1);
    C :=DemoTime/1000;

    for i := 0 to numVertices-1 do
    begin
      Y := 1 + 0.1*((1 - cos(LU[i].X + C*5)) +
                    (1 - cos(LU[i].Y + C*7)) +
                    (1 - cos(LU[i].Z + C*8)));
      blob.vertex[i].x := sphere.vertex[i].x * Y;
      blob.vertex[i].y := sphere.vertex[i].y * Y;
      blob.vertex[i].z := sphere.vertex[i].z * Y;
    end;

    glScale(0.015, 0.015, 0.015);
    glRotate(-DemoTime/50, 0, 0, 1);
    glBindTexture(GL_TEXTURE_2D, ColorsTex);
    renderBlob(blob);
  glPopMatrix();


  T :=Round(DemoTime/15);
  glWrite(350,  10+T, 'A 64K Demo by Jan Horn');
  glWrite(300, -60+T, 'Well that is all there is to this 64K demo');
  glWrite(300, -100+T, 'I started it on the morning Optimize 2001');
  glWrite(300, -140+T, 'and just didnt have enough time to finish');
  glWrite(300, -180+T, 'it. I also wasted to much time trying to get');
  glWrite(300, -220+T, 'a midi file in the app resource and playing');
  glWrite(300, -260+T, 'it from there.');
  glWrite(300, -320+T, 'Total coding time = 2 hours.');
  glWrite(300, -380+T, 'The demo has to submited now and I still');
  glWrite(300, -420+T, 'have a few KB left. Guess I wont finish it now');
  glWrite(300, -480+T, 'The demo and source will be available on ');
  glWrite(300, -520+T, 'my site as usual.');
  glWrite(300, -580+T, '           www.sulaco.co.za');
end;


procedure drawDemo;
var I, J : Integer;
    C, J1, J2 : glFloat;
    X, Y : glFloat;
    Angle : glFloat;
    A1, A2, A3, A4 : glFloat;
    DemoTime : Integer;
begin

  DemoTime :=ElapsedTime;

  // --- Drawing the tunnel --- //
  glDisable(GL_BLEND);
  glPushMatrix();
    glTranslatef(0.0,0.0,-2);

    Angle := DemoTime/14;

    //--- Outside tunnel ---//
    // setup tunnel coordinates
    A1 := sin(Angle/27);
    A2 := cos(Angle/25);
    A3 := cos(Angle/13);
    A4 := sin(Angle/17);
    for I :=0 to 16 do
    begin
      X :=cos(PI_8*I);
      Y :=sin(PI_8*I);
      for J :=0 to 32 do
      begin
        Tunnels[I, J].X :=(3 - J/12)*X + 2.0*sin((Angle+2*j)/27) + cos((Angle+2*j)/13) - 2*A1 - A3;
        Tunnels[I, J].Y :=(3 - J/12)*Y + 2.5*cos((Angle+2*j)/25) + sin((Angle+2*j)/17) - 2*A2 - A4;
        Tunnels[I, J].Z :=-J;
      end;
    end;

    // draw tunnel and fade out last few
    glBindTexture(GL_TEXTURE_2D, BlueTex);
    For J :=0 to 31 do
    begin
      J1 :=J/32 + Angle*TUNNEL_SPEED;        // precalculate texture v coords for speed
      J2 :=(J+1)/32 + Angle*TUNNEL_SPEED;

      // near the end of the tunnel, fade the effect away
      if J > 24 then
        C :=1.0-(J-24)/10
      else
        C :=1.0;

      // fade in tunnel
      if DemoTime < 500 then
        C :=C*DemoTime/500;

      glColor3f(C, C, C);

      glBegin(GL_QUADS);
        For I :=0 to 15 do
        begin
          glTexCoord2f((I-1)/8, J1); glVertex3f(Tunnels[ I,   J ].X, Tunnels[ I,   J ].Y, Tunnels[ I,   J ].Z);
          glTexCoord2f(( I )/8, J1); glVertex3f(Tunnels[I+1,  J ].X, Tunnels[I+1,  J ].Y, Tunnels[I+1,  J ].Z);
          glTexCoord2f(( I )/8, J2); glVertex3f(Tunnels[I+1, J+1].X, Tunnels[I+1, J+1].Y, Tunnels[I+1, J+1].Z);
          glTexCoord2f((I-1)/8, J2); glVertex3f(Tunnels[ I,  J+1].X, Tunnels[ I,  J+1].Y, Tunnels[ I,  J+1].Z);
        end;
      glEnd();
    end;
    glColor3f(1, 1, 1);
  glPopMatrix;

  if (DemoTime > 4000) AND (DemoTime < 22000) then drawBlob;
  if (DemoTime > 22000) AND (DemoTime < 42000) then drawTentacles;
  if (DemoTime > 44000) then
   ShowScroller;
end;


procedure initData;
var I : Integer;
begin
  LoadTexture('Colors.bmp', ColorsTex, TRUE);     // Load the Texture
  LoadTexture('Blue.bmp', BlueTex, TRUE);         // Load the Texture

  CreateSphere(blob);
  Sphere :=Blob;
  for I :=0 to numVertices-1 do
  begin
    LU[i].X := ArcTan(sphere.vertex[i].x, sphere.vertex[i].y) * 5;
    LU[i].Y := ArcTan(sphere.vertex[i].x, sphere.vertex[i].z) * 6;
    LU[i].Z := ArcTan(sphere.vertex[i].y, sphere.vertex[i].z) * 8;
  end;

  // Initialise tentacles
  CubeDL :=glGenLists(1);
  glNewList(CubeDL, GL_COMPILE);
  glBegin(GL_QUADS);
    // Front Face
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
    // Back Face
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
    // Top Face
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    // Bottom Face
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    // Right face
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
    // Left Face
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
  glEnd();
  glEndList();
end;



end.
