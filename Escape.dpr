program Escape;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SharedKernel.Core in 'SharedKernel\SharedKernel.Core.pas',
  SharedKernel.Containers in 'SharedKernel\SharedKernel.Containers.pas',
  SharedKernel.Streams in 'SharedKernel\SharedKernel.Streams.pas',
  SharedKernel.ObjectHelper in 'SharedKernel\SharedKernel.ObjectHelper.pas',
  SharedKernel.Reflection in 'SharedKernel\SharedKernel.Reflection.pas',
  SharedKernel.Collections in 'SharedKernel\SharedKernel.Collections.pas',
  SharedKernel.XmlParser in 'SharedKernel\SharedKernel.XmlParser.pas',
  SharedKernel.Enumerable in 'SharedKernel\SharedKernel.Enumerable.pas',
  SharedKernel.Properties in 'SharedKernel\SharedKernel.Properties.pas';

begin
  ReportMemoryLeaksOnShutdown := true;

  try
    Writeln('Press any key to continue');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
