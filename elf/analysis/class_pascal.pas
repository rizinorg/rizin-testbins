program class_pascal;
{$MODE OBJFPC}
type
  Polygon = class
  private
  _width,_height : Integer;
  public
     constructor Create; overload;
     function set_values(width,height: integer):integer;
     procedure area;virtual;
     procedure sides;virtual;
  end;

  Rectangle = class(Polygon)
  public
    procedure area;override;
    procedure sides;override;
  end;
  Triangle = class(Polygon)
  public
    procedure area;override;
    procedure sides;override;
  end;

  constructor Polygon.Create; overload;
  begin
    _width := 0;
    _height := 0;
  end;

  function Polygon.set_values(width,height: integer):integer;
  begin
    _width := width;
    _height := height;
  end;

  procedure Polygon.area;
  begin
    writeln(0);
  end;

  procedure Polygon.sides;
  begin
    writeln(0);
  end;

  procedure Rectangle.area;
  begin
    writeln(_width * _height);
  end;

  procedure Rectangle.sides;
  begin
    writeln(4);
  end;
  
  procedure Triangle.area;
  begin
    writeln(_width * _height / 2 :0:0);
  end;

  procedure Triangle.sides;
  begin
    writeln(3);
  end;

 
 
var
 po,po1,po2:Polygon;  
begin
 po := Polygon.Create;
 po.set_values(1,2);
 po.area;
 po.sides;
 po1 := Rectangle.Create;
 po1.set_values(3,4);
 po1.area;
 po1.sides;
 po2 := Triangle.Create;
 po2.set_values(3,4);
 po2.area;
 po2.sides;
end.
