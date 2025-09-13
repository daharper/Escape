program EscapeTests;

{$DEFINE TESTINSIGHT}

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  SharedKernel.Tests.StreamsFixture in 'SharedKernel.Tests\SharedKernel.Tests.StreamsFixture.pas',
  SharedKernel.Containers in 'SharedKernel\SharedKernel.Containers.pas',
  SharedKernel.Core in 'SharedKernel\SharedKernel.Core.pas',
  SharedKernel.Streams in 'SharedKernel\SharedKernel.Streams.pas',
  SharedKernel.Mocks.Customer in 'SharedKernel.Mocks\SharedKernel.Mocks.Customer.pas',
  SharedKernel.Reflection in 'SharedKernel\SharedKernel.Reflection.pas',
  SharedKernel.ObjectHelper in 'SharedKernel\SharedKernel.ObjectHelper.pas',
  SharedKernel.Collections in 'SharedKernel\SharedKernel.Collections.pas',
  SharedKernel.XmlParser in 'SharedKernel\SharedKernel.XmlParser.pas',
  SharedKernel.Enumerable in 'SharedKernel\SharedKernel.Enumerable.pas',
  SharedKernel.Properties in 'SharedKernel\SharedKernel.Properties.pas',
  SharedKernel.Tests.CollectionsFixture in 'SharedKernel.Tests\SharedKernel.Tests.CollectionsFixture.pas';

{ keep comment here to protect the following conditional from being removed by the IDE when adding a unit }
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  ReportMemoryLeaksOnShutdown := true;

  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
