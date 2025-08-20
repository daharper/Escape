program Escape;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SharedKernel.Integrity in 'SharedKernel\SharedKernel.Integrity.pas',
  SharedKernel.Core in 'SharedKernel\SharedKernel.Core.pas',
  SharedKernel.Container in 'SharedKernel\SharedKernel.Container.pas',
  SharedKernel.Stream in 'SharedKernel\SharedKernel.Stream.pas',
  SharedKernel.StreamHelper in 'SharedKernel\SharedKernel.StreamHelper.pas',
  SharedKernel.ObjectHelper in 'SharedKernel\SharedKernel.ObjectHelper.pas',
  SharedKernel.Reflection in 'SharedKernel\SharedKernel.Reflection.pas';

begin
  try
    Writeln('Press any key to continue');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
