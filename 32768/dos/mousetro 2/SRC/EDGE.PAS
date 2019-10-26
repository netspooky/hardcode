unit Edge;
interface
uses
   Tables;

procedure EdgeArea(x, y, w, h          :Integer;
                   S, T                :Word);

implementation

{$L edge}
procedure EdgeArea; external;

end.
