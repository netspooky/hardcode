unit Copy;
interface

procedure CopyArea(x, y, w, h          :Integer;
                   S, T                :Word);

implementation

{$L copy}
procedure CopyArea; external;

end.
