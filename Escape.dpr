program Escape;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SharedKernel.Integrity in 'SharedKernel\SharedKernel.Integrity.pas',
  SharedKernel.Core in 'SharedKernel\SharedKernel.Core.pas',
  SharedKernel.Container in 'SharedKernel\SharedKernel.Container.pas',
  SharedKernel.Stream in 'SharedKernel\SharedKernel.Stream.pas',
  SharedKernel.Stream.Helper in 'SharedKernel\SharedKernel.Stream.Helper.pas';

begin
  try
    Writeln('Press any key to continue');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
