unit Gray;
interface
uses
   Tables;

procedure GrayArea(x, y, w, h          :Integer;
                   S, T                :Word);

implementation

{$L gray}
procedure GrayArea; external;

end.
