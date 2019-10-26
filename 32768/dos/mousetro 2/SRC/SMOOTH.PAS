unit Smooth;
interface
uses
   Tables;

procedure SmoothArea(x, y, w, h        :Integer;
                     S, T              :Word);

implementation

{$L smooth}
procedure SmoothArea; external;

end.
