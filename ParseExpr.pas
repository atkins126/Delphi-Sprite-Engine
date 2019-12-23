unit ParseExpr;
{--------------------------------------------------------------
| TExpressionParser
| a flexible and fast expression parser for logical and
| mathematical functions
| Author: Egbert van Nes
| With contributions of: John Bultena and Ralf Junker
| Status: Freeware with source
| Version: 1.1
| Date: Jan 2001
| Homepage: http://www.slm.wau.nl/wkao/parseexpr.html
|
| The fast evaluation algorithm ('pseudo-compiler' generating a linked list
| that evaluates fast) is based upon TParser - an extremely fast component
| for parsing and evaluating mathematical expressions
|('pseudo-compiled' code is only 40-80% slower than compiled Delphi code).
|
| see also: http://www.datalog.ro/delphi/parser.html
|   (Renate Schaaf (schaaf@math.usu.edu), 1993
|    Alin Flaider (aflaidar@datalog.ro), 1996
|    Version 9-10: Stefan Hoffmeister, 1996-1997)
|
| I used this valuable free parser for some years but needed to add logical
| operands, which was more difficult for me than rewriting the parser.
|
| TExpressionParser is approximately equally fast in evaluating
| expressions as TParser, but the compiling is made object oriented,
| and programmed recursively, requiring much less code and making
| it easier to customize the parser. Furthermore, there are several operands added:
|   comparison: > < <> = <= >= (work also on strings)
|   logical: and or xor not
|   factorial: !
|   percentage: %
|   assign to variables: :=
|   user defined functions can have maximal maxArg (=4) parameters
|   set MaxArg (in unit ParseClass) to a higher value if needed.
|
| The required format of the expression is Pascal style with
| the following additional operands:
|    - factorial (x!)
|    - power (x^y)
|    - pecentage (x%)
|
| Implicit multiplying is not supported: e.g. (X+1)(24-3) generates
| a syntax error and should be replaced by (x+1)*(24-3)
|
| Logical functions evaluate in 0 if False and 1 if True
| The AsString property returns True/False if the expression is logical.
|
| The comparison functions (< <> > etc.) work also with string constants ('string') and string
| variables and are not case sensitive then.
|
| The precedence of the operands is little different from Pascal (Delphi), giving
| a lower precedence to logical operands, as these only act on Booleans
| (and not on integers like in Pascal)
|
|  1 (highest): ! -x +x %
|  2: ^
|  3: * / div mod
|  4: + -
|  5: > >= < <= <> =
|  6: not
|  7: or and xor
|  8: (lowest): :=
|
| This precedence order is easily customizable by overriding/changing
| FillExpressList (the precedence order is defined there)
|
| You can use user-defined variables in the expressions and also assign to
| variables using the := operand
|
| The use of this object is very simple, therefore it doesn't seem necessary
| to make a non-visual component of it.
|
| NEW IN VERSION 1.1:
| Optimization, increasing the efficiency for evaluating an expression many times
| (with a variable in the expression).
| The 'compiler' then removes constant expressions and replaces
| these with the evaluated result.
| e.g.  4*4*x becomes 16*x
|       ln(5)+3*x becomes 1.609437912+3*x
| limitation:
|       4*x+3+3+5 evaluates as 4*x+3+3+5  (due to precedence rules)
| whereas:
|       4*x+(3+3+5) becomes 4*x+11 (use brackets to be sure that constant
|       expressions are removed by the compiler)
|
|  Hexadecimal notation supported: $FF is converted to 255
|  the Hexadecimals characted ($) is adjustable by setting the HexChar
|  property
|
|  The variable DecimalSeparator (SysUtils) now determines the
|  decimal separator. If the decimal separator is a comma then the
|  function argument separator is a semicolon ';'
|
|  'in' operator for strings added (John Bultena):
|     'a' in 'dasad,sdsd,a,sds' evaluates True
|     's' in 'dasad,sdsd,a,sds' evaluates False
|
|
|---------------------------------------------------------------}
interface
uses OObjects, SysUtils, Classes, ParseClass;
type

  TExpressionParser = class
  private
    FHexChar: Char;
    FArgSeparator: Char;
    FOptimize: Boolean;
    WordsList: TSortedCollection;
    ConstantsList: TOCollection;
    Expressions: TStringList;
    LastRec: PExpressionRec;
    CurrentRec: PExpressionRec;
    FCurrentIndex: Integer;
    function ParseString(AnExpression: string): TExprCollection;
    function MakeTree(var Expr: TExprCollection): PExpressionRec;
    function MakeRec: PExpressionRec;
    function MakeLinkedList(ExprRec: PExpressionRec): PDouble;
    function CompileExpression(AnExpression: string): Integer;
    function GetResults(AIndex: Integer): Double;
    function GetAsString(AIndex: Integer): string;
    function isBoolean: Boolean;
    function GetAsBoolean(AIndex: Integer): Boolean;
    procedure Check(AnExprList: TExprCollection);
    function CheckArguments(ExprRec: PExpressionRec): Boolean;
    procedure DisposeTree(ExprRec: PExpressionRec);
    procedure AddReplaceExprWord(AExprWord: TExprWord);
    function EvaluateDisposeTree(ExprRec: PExpressionRec; var isBool: Boolean):
      Double;
    function EvaluateList(ARec: PExpressionRec): Double;
    function RemoveConstants(ExprRec: PExpressionRec): PExpressionRec;
    function ResultCanVary(ExprRec: PExpressionRec): Boolean;
    procedure DisposeList(ARec: PExpressionRec);
    function GetExprSize(AIndex: Integer): Integer;
    function GetAsHexadecimal(AIndex: Integer): string;
    function GetExpression(AIndex: Integer): string;
    procedure ReplaceExprWord(OldExprWord, NewExprWord: TExprWord);
  protected
    procedure FillExpressList; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DefineVariable(AVarName: string; AValue: PDouble);
    procedure DefineStringVariable(AVarName: string; AValue: PString);
    procedure DefineFunction(AFunctName: string; AFuncAddress: TDoubleFunc;
      NArguments: Integer);
    procedure ReplaceFunction(OldName: string; AFunction: TObject);
    function Evaluate(AnExpression: string): Double;
    function EvaluateCurrent: Double; //fastest
    function AddExpression(AnExpression: string): Integer;
    procedure ClearExpressions;
    procedure GetGeneratedVars(AList: TList);
    property HexChar: Char read FHexChar write FHexChar;
    property ArgSeparator: Char read FArgSeparator write FArgSeparator;
    property ExpressionSize[AIndex: Integer]: Integer read GetExprSize;
    property Expression[AIndex: Integer]: string read GetExpression;
    property AsFloat[AIndex: Integer]: Double read GetResults;
    property AsString[AIndex: Integer]: string read GetAsString;
    property AsBoolean[AIndex: Integer]: Boolean read GetAsBoolean;
    property AsHexadecimal[AIndex: Integer]: string read GetAsHexadecimal;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    property Optimize: Boolean read FOptimize write FOptimize;
    //if optimize is selected, constant expressions are tried to remove
    //such as: 4*4*x is evaluated as 16*x and exp(1)-4*x is repaced by 2.17 -4*x
  end;

  {------------------------------------------------------------------
  Example of creating a user-defined Parser,
  here are Pascal operators replaced by C++ style,
  note that sometimes the ParseString function needs to be changed,
  if you define new operators (characters).
  Also some special checks do not work: like 'not not x' should be
  replaced by 'x', but this does not work with !!x (c style)
  --------------------------------------------------------------------}
  TCStyleParser = class(TExpressionParser)
  protected
    procedure FillExpressList; override;
  end;

implementation
uses Math;

{ TExpressionParser }

function TExpressionParser.CompileExpression(AnExpression: string): Integer;
var
  ExpColl: TExprCollection;
  ExprTree: PExpressionRec;
begin
  ExprTree := nil;
  ExpColl := nil;
  try
    //    FCurrentExpression := anExpression;
    ExpColl := ParseString(LowerCase(AnExpression));
    Check(ExpColl);
    ExprTree := MakeTree(ExpColl);
    CurrentRec := nil;
    if CheckArguments(ExprTree) then
    begin
      if Optimize then
      try
        ExprTree := RemoveConstants(ExprTree);
      except
        on EMathError do
        begin
          ExprTree := nil;
          raise;
        end;
      end;
      // all constant expressions are evaluated and replaced by variables
      if ExprTree.ExprWord.isVariable then
        CurrentRec := ExprTree
      else
        MakeLinkedList(ExprTree);
    end
    else
      raise
        EParserException.Create('Syntax error: function or operand has too few arguments');
    Expressions.AddObject(AnExpression, TObject(CurrentRec));
  except
    ExpColl.Free;
    DisposeTree(ExprTree);
    raise;
  end;
  Result := Expressions.Count - 1;
end;

constructor TExpressionParser.Create;
begin
  HexChar := '$';
  if FormatSettings.DecimalSeparator = ',' then
    ArgSeparator := ';'
  else
    ArgSeparator := ',';
  WordsList := TExpressList.Create(30);
  ConstantsList := TOCollection.Create(10);
  Expressions := TStringList.Create;
  Expressions.Sorted := False;
  Optimize := True;
  FillExpressList;
end;

destructor TExpressionParser.Destroy;
begin
  inherited;
  WordsList.Free;
  ConstantsList.Free;
  ClearExpressions;
  Expressions.Free;
end;

function TExpressionParser.CheckArguments(ExprRec: PExpressionRec): Boolean;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    Result := True;
    for I := 0 to ExprWord.NFunctionArg - 1 do
      if Args[I] = nil then
      begin
        Result := False;
        Exit;
      end
      else
      begin
        Result := CheckArguments(ArgList[I]);
        if not Result then
          Exit;
      end;
  end;
end;

function TExpressionParser.ResultCanVary(ExprRec: PExpressionRec): Boolean;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    Result := ExprWord.CanVary;
    if not Result then
      for I := 0 to ExprWord.NFunctionArg - 1 do
        if ResultCanVary(ArgList[I]) then
        begin
          Result := True;
          Exit;
        end
  end;
end;

function TExpressionParser.RemoveConstants(ExprRec: PExpressionRec):
  PExpressionRec;
var
  I: Integer;
  isBool: Boolean;
  D: Double;
begin
  Result := ExprRec;
  with ExprRec^ do
  begin
    if not ResultCanVary(ExprRec) then
    begin
      if not ExprWord.isVariable then
      begin
        D := EvaluateDisposeTree(ExprRec, isBool);
        Result := MakeRec;
        if isBool then
          Result.ExprWord := TBooleanConstant.CreateAsDouble('', D)
        else
          Result.ExprWord := TDoubleConstant.CreateAsDouble('', D);
        //TDoubleConstant(Result.ExprWord).Value := D;
        Result.Oper := Result.ExprWord.DoubleFunc;
        Result.Args[0] := Result.ExprWord.AsPointer;
        ConstantsList.Add(Result.ExprWord);
      end;
    end
    else
      for I := 0 to ExprWord.NFunctionArg - 1 do
        ArgList[I] := RemoveConstants(ArgList[I]);
  end;
end;

procedure TExpressionParser.DisposeTree(ExprRec: PExpressionRec);
var
  I: Integer;
begin
  if ExprRec <> nil then
    with ExprRec^ do
    begin
      if ExprWord <> nil then
        for I := 0 to ExprWord.NFunctionArg - 1 do
          DisposeTree(ArgList[I]);
      Dispose(ExprRec);
    end;
end;

function TExpressionParser.EvaluateDisposeTree(ExprRec: PExpressionRec; var
  isBool: Boolean): Double;
begin
  if ExprRec.ExprWord.isVariable then
    CurrentRec := ExprRec
  else
    MakeLinkedList(ExprRec);
  isBool := isBoolean;
  try
    Result := EvaluateList(CurrentRec);
  finally
    DisposeList(ExprRec);
    CurrentRec := nil;
  end;
end;

function TExpressionParser.MakeLinkedList(ExprRec: PExpressionRec): PDouble;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    for I := 0 to ExprWord.NFunctionArg - 1 do
      Args[I] := MakeLinkedList(ArgList[I]);
    if ExprWord.isVariable {@Oper = @_Variable} then
    begin
      Result := Args[0];
      Dispose(ExprRec);
    end
    else
    begin
      Result := @Res;
      if CurrentRec = nil then
      begin
        CurrentRec := ExprRec;
        LastRec := ExprRec;
      end
      else
      begin
        LastRec.Next := ExprRec;
        LastRec := ExprRec;
      end;
    end;
  end;
end;

function TExpressionParser.MakeTree(var Expr: TExprCollection): PExpressionRec;
{This is the most complex routine, it breaks down the expression and makes
a linked tree which is used for fast function evaluations
it is implemented recursively}
var
  I, IArg, IStart, IEnd, brCount: Integer;
  FirstOper: TExprWord;
  Expr2: TExprCollection;
  Rec: PExpressionRec;
begin
  FirstOper := nil;
  IStart := 0;
  try
    Result := nil;
    repeat
      Rec := MakeRec;
      if Result <> nil then
      begin
        IArg := 1;
        Rec.ArgList[0] := Result;
      end
      else
        IArg := 0;
      Result := Rec;
      Expr.EraseExtraBrackets;
      if Expr.Count = 1 then
      begin
        Result.ExprWord := TExprWord(Expr.Items[0]);
        Result.Oper := @Result.ExprWord.DoubleFunc;
        if not Result.ExprWord.isVariable then
          Result.Oper := @Result.ExprWord.DoubleFunc
        else
        begin
          Result.Args[0] := Result.ExprWord.AsPointer;
        end;
        Exit;
      end;
      IEnd := Expr.NextOper(IStart);
      if IEnd = Expr.Count then
        raise EParserException.Create('Syntax error in expression ' +
          Expressions.Strings[CurrentIndex]);
      if TExprWord(Expr.Items[IEnd]).NFunctionArg > 0 then
      begin
        FirstOper := TExprWord(Expr.Items[IEnd]);
        Result.ExprWord := FirstOper;
        Result.Oper := FirstOper.DoubleFunc;
      end
      else
        raise EParserException.Create('Can not find operand/function');
      if not FirstOper.IsOper then
      begin // parse function arguments
        IArg := 0;
        IStart := IEnd + 1;
        IEnd := IStart;
        if TExprWord(Expr.Items[IEnd]).VarType = vtLeftBracket then
          brCount := 1
        else
          brCount := 0;
        while (IEnd < Expr.Count - 1) and (brCount <> 0) do
        begin
          Inc(IEnd);
          case TExprWord(Expr.Items[IEnd]).VarType of
            vtLeftBracket: Inc(brCount);
            vtComma:
              if brCount = 1 then
              begin
                Expr2 := TExprCollection.Create(IEnd - IStart);
                for I := IStart + 1 to IEnd - 1 do
                  Expr2.Add(Expr.Items[I]);
                Result.ArgList[IArg] := MakeTree(Expr2);
                Inc(IArg);
                IStart := IEnd;
              end;
            vtRightBracket: Dec(brCount);
          end;
        end;
        Expr2 := TExprCollection.Create(IEnd - IStart + 1);
        for I := IStart + 1 to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
      end
      else if IEnd - IStart > 0 then
      begin
        Expr2 := TExprCollection.Create(IEnd - IStart + 1);
        for I := 0 to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
        Inc(IArg);
      end;
      IStart := IEnd + 1;
      IEnd := IStart - 1;
      repeat
        IEnd := Expr.NextOper(IEnd + 1);
      until (IEnd >= Expr.Count) or
        (TFunction(Expr.Items[IEnd]).OperPrec >= TFunction(FirstOper).OperPrec);
      if IEnd <> IStart then
      begin
        Expr2 := TExprCollection.Create(IEnd);
        for I := IStart to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
      end;
      IStart := IEnd;
    until IEnd >= Expr.Count;
  finally
    Expr.Free;
    Expr := nil;
  end;
end;

function TExpressionParser.ParseString(AnExpression: string): TExprCollection;
var
  isConstant: Boolean;
  I, I1, I2, Len: Integer;
  W, S: string;
  Word: TExprWord;
  procedure ReadConstant(AnExpr: string; isHex: Boolean);
  begin
    isConstant := True;
    while (I2 <= Len) and ((AnExpr[I2] in ['0'..'9']) or
      (isHex and (AnExpr[I2] in ['a'..'f']))) do
      Inc(I2);
    if I2 <= Len then
    begin
      if AnExpr[I2] = FormatSettings.DecimalSeparator then
      begin
        Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
      if (I2 <= Len) and (AnExpr[I2] = 'e') then
      begin
        Inc(I2);
        if (I2 <= Len) and (AnExpr[I2] in ['+', '-']) then
          Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
    end;
  end;
  procedure ReadWord(AnExpr: string);
  var
    OldI2: Integer;
  begin
    isConstant := False;
    I1 := I2;
    while (I1 < Len) and (AnExpr[I1] = ' ') do
      Inc(I1);
    I2 := I1;
    if I1 <= Len then
    begin
      if AnExpr[I2] = HexChar then
      begin
        Inc(I2);
        OldI2 := I2;
        ReadConstant(AnExpr, True);
        if I2 = OldI2 then
        begin
          isConstant := False;
          while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', '_', '0'..'9']) do
            Inc(I2);
        end;
      end
      else if AnExpr[I2] = FormatSettings.DecimalSeparator then
        ReadConstant(AnExpr, False)
      else
        case AnExpr[I2] of
          '''':
            begin
              isConstant := True;
              Inc(I2);
              while (I2 <= Len) and (AnExpr[I2] <> '''') do
                Inc(I2);
              if I2 <= Len then
                Inc(I2);
            end;
          'a'..'z', '_':
            begin
              while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', '_', '0'..'9']) do
                Inc(I2);
            end;
          '>', '<':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['=', '<', '>'] then
                Inc(I2);
            end;
          '=':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['<', '>', '='] then
                Inc(I2);
            end;
          '&':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['&'] then
                Inc(I2);
            end;
          '|':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['|'] then
                Inc(I2);
            end;
          ':':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then
                Inc(I2);
            end;
          '!':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then //support for !=
                Inc(I2);
            end;
          '+', '-', '^', '/', '\', '*', '(', ')', '%', '~', '$':
            Inc(I2);
          '0'..'9':
            ReadConstant(AnExpr, False);
        else
          begin
            Inc(I2);
          end;
        end;
    end;
  end;
begin
  Result := TExprCollection.Create(10);
  I2 := 1;
  S := Trim(LowerCase(AnExpression));
  Len := Length(s);
  repeat
    ReadWord(S);
    W := Trim(Copy(S, I1, I2 - I1));
    if isConstant then
    begin
      if W[1] = HexChar then
      begin
        W[1] := '$';
        W := IntToStr(StrToInt(W));
      end;
      if W[1] = '''' then
        Word := TStringConstant.Create(W)
      else
        Word := TDoubleConstant.Create(W, W);
      Result.Add(Word);
      ConstantsList.Add(Word);
    end
    else if W <> '' then
      if WordsList.Search(Pchar(W), I) then
        Result.Add(WordsList.Items[I])
      else
      begin
        Word := TGeneratedVariable.Create(W);
        Result.Add(Word);
        WordsList.Add(Word);
      end;
  until I2 > Len;
end;

procedure TExpressionParser.Check(AnExprList: TExprCollection);

var
  I, J, K, L: Integer;
  Word: TLogicalStringOper;
begin
  AnExprList.Check;
  with AnExprList do
  begin
    I := 0;
    while I < Count do
    begin
      {----CHECK ON DOUBLE MINUS OR DOUBLE PLUS----}
      if ((TExprWord(Items[I]).Name = '-') or
        (TExprWord(Items[I]).Name = '+'))
        and ((I = 0) or
        (TExprWord(Items[I - 1]).VarType = vtComma) or
        (TExprWord(Items[I - 1]).VarType = vtLeftBracket) or
        (TExprWord(Items[I - 1]).IsOper and (TExprWord(Items[I - 1]).NFunctionArg
          = 2))) then
      begin
        {replace e.g. ----1 with +1}
        if TExprWord(Items[I]).Name = '-' then
          K := -1
        else
          K := 1;
        L := 1;
        while (I + L < Count) and ((TExprWord(Items[I + L]).Name = '-')
          or (TExprWord(Items[I + L]).Name = '+')) and ((I + L = 0) or
          (TExprWord(Items[I + L - 1]).VarType = vtComma) or
          (TExprWord(Items[I + L - 1]).VarType = vtLeftBracket) or
          (TExprWord(Items[I + L - 1]).IsOper and (TExprWord(Items[I + L -
            1]).NFunctionArg = 2))) do
        begin
          if TExprWord(Items[I + L]).Name = '-' then
            K := -1 * K;
          Inc(L);
        end;
        if L > 0 then
        begin
          Dec(L);
          for J := I + 1 to Count - 1 - L do
            Items[J] := Items[J + L];
          Count := Count - L;
        end;
        if K = -1 then
        begin
          if WordsList.Search(Pchar('-@'), J) then
            Items[I] := WordsList.Items[J];
        end
        else if WordsList.Search(Pchar('+@'), J) then
          Items[I] := WordsList.Items[J];
      end;
      {----CHECK ON DOUBLE NOT----}
      if (TExprWord(Items[I]).Name = 'not')
        and ((I = 0) or
        (TExprWord(Items[I - 1]).VarType = vtLeftBracket) or
        TExprWord(Items[I - 1]).IsOper) then
      begin
        {replace e.g. not not 1 with 1}
        K := -1;
        L := 1;
        while (I + L < Count) and (TExprWord(Items[I + L]).Name = 'not') and ((I
          + L = 0) or
          (TExprWord(Items[I + L - 1]).VarType = vtLeftBracket) or
          TExprWord(Items[I + L - 1]).IsOper) do
        begin
          K := -K;
          Inc(L);
        end;
        if L > 0 then
        begin
          if K = 1 then
          begin //remove all
            for J := I to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
          else
          begin //keep one
            Dec(L);
            for J := I + 1 to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
        end;
      end;
      {-----MISC CHECKS-----}
      if (TExprWord(Items[I]).isVariable) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).isVariable)) then
        raise EParserException.Create(TExprWord(Items[I]).Name +
          ' two space limited variables/constants');
      if (TExprWord(Items[I]).ClassType = TGeneratedVariable) and ((I < Count -
        1) and
        (TExprWord(Items[I + 1]).VarType = vtLeftBracket)) then
        raise EParserException.Create(TExprWord(Items[I]).Name +
          ' is an unknown function');
      if (TExprWord(Items[I]).VarType = vtLeftBracket) and ((I >= Count - 1) or
        (TExprWord(Items[I + 1]).VarType = vtRightBracket)) then
        raise EParserException.Create('Empty brackets ()');
      if (TExprWord(Items[I]).VarType = vtRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).VarType = vtLeftBracket)) then
        raise EParserException.Create('Missing operand between )(');
      if (TExprWord(Items[I]).VarType = vtRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).isVariable)) then
        raise
          EParserException.Create('Missing operand between ) and constant/variable');
      if (TExprWord(Items[I]).VarType = vtLeftBracket) and ((I > 0) and
        (TExprWord(Items[I - 1]).isVariable)) then
        raise
          EParserException.Create('Missing operand between constant/variable and (');

      {-----CHECK ON INTPOWER------}
      if (TExprWord(Items[I]).Name = '^') and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).ClassType = TDoubleConstant) and
        (Pos(FormatSettings.DecimalSeparator, TExprWord(Items[I + 1]).Name) = 0)) then
        if WordsList.Search(Pchar('^@'), J) then
          Items[I] := WordsList.Items[J]; //use the faster intPower if possible
      Inc(I);
    end;
    {-----CHECK STRING COMPARE--------}
    for I := Count - 3 downto 0 do
    begin
      if (TExprWord(Items[I]).VarType = vtString) and
        (TExprWord(Items[I + 2]).VarType = vtString) then
      begin
        Word := TLogicalStringOper.Create(TExprWord(Items[I + 1]).Name,
          TExprWord(Items[I]), TExprWord(Items[I + 2]));
        Items[I] := Word;
        for J := I + 1 to Count - 3 do
          Items[J] := Items[J + 2];
        Count := Count - 2;
        ConstantsList.Add(Word);
      end;
    end;
  end;
end;

procedure TExpressionParser.DefineFunction(AFunctName: string;
  AFuncAddress: TDoubleFunc; NArguments: Integer);
begin
  AddReplaceExprWord(TFunction.Create(AFunctName, AFuncAddress, NArguments));
end;

procedure TExpressionParser.DefineVariable(AVarName: string; AValue: PDouble);
begin
  AddReplaceExprWord(TDoubleVariable.Create(AVarName, AValue));
end;

procedure TExpressionParser.DefineStringVariable(AVarName: string; AValue:
  PString);
begin
  AddReplaceExprWord(TStringVariable.Create(AVarName, AValue));
end;

function TExpressionParser.Evaluate(AnExpression: string): Double;
begin
  if AnExpression <> '' then
  begin
    AddExpression(AnExpression);
    Result := EvaluateList(CurrentRec);
  end
  else
    Result := FNan;
end;

function TExpressionParser.EvaluateList(ARec: PExpressionRec): Double;
var
  LastRec1: PExpressionRec;
begin
  if ARec <> nil then
  begin
    LastRec1 := ARec;
    while LastRec1^.Next <> nil do
      with LastRec1^ do
      begin
        Oper(LastRec1);
        LastRec1 := Next;
      end;
    LastRec1^.Oper(LastRec1);
    Result := LastRec1.Res;
  end
  else
    Result := FNan;
end;

function TExpressionParser.isBoolean: Boolean;
var
  LastRec1: PExpressionRec;
begin
  if CurrentRec = nil then
    Result := False
  else
  begin
    LastRec1 := CurrentRec;
      //LAST operand should be boolean -otherwise If(,,) doesn't work
    while (LastRec1^.Next <> nil) do
      LastRec1 := LastRec1^.Next;
    Result := (LastRec1.ExprWord <> nil) and (LastRec1.ExprWord.VarType =
      vtBoolean);
  end;
end;

function TExpressionParser.MakeRec: PExpressionRec;
var
  I: Integer;
begin
  Result := New(PExpressionRec);
  Result.Oper := nil;
  for I := 0 to MaxArg - 1 do
    Result.ArgList[I] := nil;
  Result.Res := 0;
  Result.Next := nil;
  Result.ExprWord := nil;
end;

function TExpressionParser.AddExpression(AnExpression: string): Integer;
begin
  if AnExpression <> '' then
  begin
    Result := Expressions.IndexOf(AnExpression);
    if Result < 0 then
      Result := CompileExpression(AnExpression)
    else
      CurrentRec := PExpressionRec(Expressions.Objects[Result]);
  end
  else
    Result := -1;
  CurrentIndex := Result;
end;

function TExpressionParser.GetResults(AIndex: Integer): Double;
begin
  if AIndex >= 0 then
  begin
    CurrentRec := PExpressionRec(Expressions.Objects[AIndex]);
    Result := EvaluateList(CurrentRec);
  end
  else
    Result := FNan;
end;

procedure TExpressionParser.GetGeneratedVars(AList: TList);
var
  I: Integer;
begin
  AList.Clear;
  with WordsList do
    for I := 0 to Count - 1 do
    begin
      if TObject(Items[I]).ClassType = TGeneratedVariable then
        AList.Add(Items[I]);
    end;
end;

function TExpressionParser.GetAsBoolean(AIndex: Integer): Boolean;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  if not isBoolean then
    raise EParserException.Create('Expression is not boolean')
  else if (D < 0.1) and (D > -0.1) then
    Result := False
  else
    Result := True;
end;

function TExpressionParser.GetAsString(AIndex: Integer): string;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  if isBoolean then
  begin
    if (D < 0.1) and (D > -0.1) then
      Result := 'False'
    else if (D > 0.9) and (D < 1.1) then
      Result := 'True'
    else
      Result := Format('%.10g', [D]);
  end
  else
    Result := Format('%.10g', [D]);
end;

procedure _Power(Param: PExpressionRec);
begin
  with Param^ do
    Res := Power(Args[0]^, Args[1]^);
end;

procedure _IntPower(Param: PExpressionRec);
begin
  with Param^ do
    Res := IntPower(Args[0]^, Round(Args[1]^));
end;

procedure _ArcCos(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcCos(Args[0]^);
end;

procedure _ArcSin(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcSin(Args[0]^);
end;

procedure _ArcSinh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcSinh(Args[0]^);
end;

procedure _ArcCosh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcCosh(Args[0]^);
end;

procedure _ArcTanh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcTanh(Args[0]^);
end;

procedure _ArcTan2(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcTan2(Args[0]^, Args[1]^);
end;

procedure _Cosh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Cosh(Args[0]^);
end;

procedure _tanh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Tanh(Args[0]^);
end;

procedure _Sinh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sinh(Args[0]^);
end;

procedure _DegToRad(Param: PExpressionRec);
begin
  with Param^ do
    Res := DegToRad(Args[0]^);
end;

procedure _RadToDeg(Param: PExpressionRec);
begin
  with Param^ do
    Res := RadToDeg(Args[0]^);
end;

procedure _ln(Param: PExpressionRec);
begin
  with Param^ do
    Res := Ln(Args[0]^);
end;

procedure _log10(Param: PExpressionRec);
begin
  with Param^ do
    Res := Log10(Args[0]^);
end;

procedure _logN(Param: PExpressionRec);
begin
  with Param^ do
    Res := LogN(Args[0]^, Args[1]^);
end;

procedure _negate(Param: PExpressionRec);
begin
  with Param^ do
    Res := -Args[0]^;
end;

procedure _plus(Param: PExpressionRec);
begin
  with Param^ do
    Res := +Args[0]^;
end;

procedure _exp(Param: PExpressionRec);
begin
  with Param^ do
    Res := Exp(Args[0]^);
end;

procedure _sin(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sin(Args[0]^);
end;

procedure _Cos(Param: PExpressionRec);
begin
  with Param^ do
    Res := Cos(Args[0]^);
end;

procedure _tan(Param: PExpressionRec);
begin
  with Param^ do
    Res := Tan(Args[0]^);
end;

procedure _Add(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ + Args[1]^;
end;

procedure _Assign(Param: PExpressionRec);
begin
  with Param^ do
  begin
    Res := Args[1]^;
    Args[0]^ := Args[1]^;
  end;
end;

procedure _mult(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ * Args[1]^;
end;

procedure _minus(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ - Args[1]^;
end;

procedure _realDivide(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ / Args[1]^;
end;

procedure _Div(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) div Round(Args[1]^);
end;

procedure _mod(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) mod Round(Args[1]^);
end;

//procedure _pi(Param: PExpressionRec);
//begin
//  with Param^ do
//    Res := Pi;
//end;

procedure _random(Param: PExpressionRec);
begin
  with Param^ do
    Res := Random;
end;

procedure _randG(Param: PExpressionRec);
begin
  with Param^ do
    Res := RandG(Args[0]^, Args[1]^);
end;

procedure _gt(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ > Args[1]^);
end;

procedure _ge(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ + 1E-30 >= Args[1]^);
  ;
end;

procedure _lt(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ < Args[1]^);
  ;
end;

procedure _eq(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Abs(Args[0]^ - Args[1]^) < 1E-30);
  ;
end;

procedure _ne(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Abs(Args[0]^ - Args[1]^) > 1E-30);
  ;
end;

procedure _le(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ <= Args[1]^ + 1E-30);
  ;
end;

procedure _if(Param: PExpressionRec);
begin
  with Param^ do
    if Boolean(Round(Args[0]^)) then
      Res := Args[1]^
    else
      Res := Args[2]^;
end;

procedure _And(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) and Round(Args[1]^);
  ;
end;

procedure _or(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) or Round(Args[1]^);
  ;
end;

procedure _not(Param: PExpressionRec);
var
  b: integer;
begin
  with Param^ do
  begin
    b := Round(Args[0]^);
    Res := byte(not boolean(b));
  end;
end;

procedure _xor(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) xor Round(Args[1]^);
  ;
end;

procedure _round(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^);
end;

procedure _trunc(Param: PExpressionRec);
begin
  with Param^ do
    Res := Trunc(Args[0]^);
end;

procedure _sqrt(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sqrt(Args[0]^);
end;

procedure _Percentage(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ * 0.01;
end;

procedure _factorial(Param: PExpressionRec);
  function Factorial(X: Extended): Extended;
  begin
    if X <= 1.1 then
      Result := 1
    else
      Result := X * Factorial(X - 1);
  end;
begin
  with Param^ do
    Res := Factorial(Round(Args[0]^));
end;

procedure _sqr(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sqr(Args[0]^);
end;

procedure _Abs(Param: PExpressionRec);
begin
  with Param^ do
    Res := Abs(Args[0]^);
end;

procedure _max(Param: PExpressionRec);
begin
  with Param^ do
    if Args[0]^ < Args[1]^ then
      Res := Args[1]^
    else
      Res := Args[0]^
end;

procedure _min(Param: PExpressionRec);
begin
  with Param^ do
    if Args[0]^ > Args[1]^ then
      Res := Args[1]^
    else
      Res := Args[0]^
end;

procedure TExpressionParser.FillExpressList;
begin
  with WordsList do
  begin
    Add(TLeftBracket.Create('(', nil));
    Add(TRightBracket.Create(')', nil));
    Add(TComma.Create(ArgSeparator, nil));
    Add(TDoubleConstant.CreateAsDouble('pi', Pi));
    Add(TVaryingFunction.Create('random', _random, 0));
    // definitions of operands:
    // the last number is used to determine the precedence
    Add(TFunction.CreateOper('!', _factorial, 1,
      True { isOperand}, 10 {precedence}));
    Add(TFunction.CreateOper('%', _Percentage, 1, True, 10));
    Add(TFunction.CreateOper('-@', _negate, 1, True, 10));
    Add(TFunction.CreateOper('+@', _plus, 1, True, 10));
    Add(TFunction.CreateOper('^', _Power, 2, True, 20));
    Add(TFunction.CreateOper('^@', _IntPower, 2, True, 20));
    Add(TFunction.CreateOper('*', _mult, 2, True, 30));
    Add(TFunction.CreateOper('/', _realDivide, 2, True, 30));
    Add(TFunction.CreateOper('div', _Div, 2, True, 30));
    Add(TFunction.CreateOper('mod', _mod, 2, True, 30));
    Add(TFunction.CreateOper('+', _Add, 2, True, 40));
    Add(TFunction.CreateOper('-', _minus, 2, True, 40));
    Add(TBooleanFunction.CreateOper('>', _gt, 2, True, 50));
    Add(TBooleanFunction.CreateOper('>=', _ge, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<=', _le, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<', _lt, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<>', _ne, 2, True, 50));
    Add(TBooleanFunction.CreateOper('=', _eq, 2, True, 50));
    Add(TBooleanFunction.CreateOper('in', _eq, 2, True, 10));
    Add(TBooleanFunction.CreateOper('not', _not, 1, True, 60));
    Add(TBooleanFunction.CreateOper('or', _or, 2, True, 70));
    Add(TBooleanFunction.CreateOper('and', _And, 2, True, 70));
    Add(TBooleanFunction.CreateOper('xor', _xor, 2, True, 70));
    Add(TFunction.CreateOper(':=', _Assign, 2, True, 200));
    Add(TFunction.Create('exp', _exp, 1));
    Add(TFunction.Create('if', _if, 3));
    Add(TVaryingFunction.Create('randg', _randG, 2));
    Add(TFunction.Create('sqr', _sqr, 1));
    Add(TFunction.Create('sqrt', _sqrt, 1));
    Add(TFunction.Create('abs', _Abs, 1));
    Add(TFunction.Create('round', _round, 1));
    Add(TFunction.Create('trunc', _trunc, 1));
    Add(TFunction.Create('ln', _ln, 1));
    Add(TFunction.Create('log10', _log10, 1));
    Add(TFunction.Create('logN', _logN, 2));
    Add(TFunction.Create('power', _Power, 2));
    Add(TFunction.Create('pow', _Power, 2));
    Add(TFunction.Create('intpower', _IntPower, 2));
    Add(TFunction.Create('max', _max, 2));
    Add(TFunction.Create('min', _min, 2));
    Add(TFunction.Create('sin', _sin, 1));
    Add(TFunction.Create('cos', _Cos, 1));
    Add(TFunction.Create('tan', _tan, 1));
    Add(TFunction.Create('arcsin', _ArcSin, 1));
    Add(TFunction.Create('arccos', _ArcCos, 1));
    Add(TFunction.Create('arctan2', _ArcTan2, 2));
    Add(TFunction.Create('sinh', _Sinh, 1));
    Add(TFunction.Create('cosh', _Cosh, 1));
    Add(TFunction.Create('tanh', _tanh, 1));
    Add(TFunction.Create('arcsinh', _ArcSinh, 1));
    Add(TFunction.Create('arccosh', _ArcCosh, 1));
    Add(TFunction.Create('arctanh', _ArcTanh, 1));
    Add(TFunction.Create('degtorad', _DegToRad, 1));
    Add(TFunction.Create('radtodeg', _RadToDeg, 1));
  end;
end;

procedure TExpressionParser.ReplaceFunction(OldName: string; AFunction:
  TObject);
var
  I: Integer;
begin
  if WordsList.Search(Pchar(OldName), I) then
  begin
    ReplaceExprWord(WordsList.Items[i], TExprWord(AFunction));
    WordsList.AtFree(I);
  end;
  if AFunction <> nil then
    WordsList.Add(AFunction);
end;

procedure TExpressionParser.ClearExpressions;
var
  I: Integer;
begin
  for I := 0 to Expressions.Count - 1 do
    DisposeList(PExpressionRec(Expressions.Objects[I]));
  Expressions.Clear;
  CurrentIndex := -1;
  CurrentRec := nil;
  LastRec := nil;
end;

procedure TExpressionParser.DisposeList(ARec: PExpressionRec);
var
  TheNext: PExpressionRec;
begin
  repeat
    TheNext := ARec.Next;
    Dispose(ARec);
    ARec := TheNext;
  until ARec = nil;
end;

function TExpressionParser.EvaluateCurrent: Double;
begin
  Result := EvaluateList(CurrentRec);
end;

function TExpressionParser.GetAsHexadecimal(AIndex: Integer): string;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  Result := Format(HexChar + '%x', [Round(D)]);
end;

function TExpressionParser.GetExpression(AIndex: Integer): string;
begin
  Result := Expressions.Strings[AIndex];
end;

function TExpressionParser.GetExprSize(AIndex: Integer): Integer;
var
  TheNext, ARec: PExpressionRec;
begin
  Result := 0;
  if AIndex >= 0 then
  begin
    ARec := PExpressionRec(Expressions.Objects[AIndex]);
    while ARec <> nil do
    begin
      TheNext := ARec.Next;
      if (ARec.ExprWord <> nil) and
        not ARec.ExprWord.isVariable then
        Inc(Result);
      ARec := TheNext;
    end;
  end;
end;

procedure TExpressionParser.ReplaceExprWord(OldExprWord, NewExprWord:
  TExprWord);
var
  i, j: integer;
  Rec: PExpressionRec;
  p, pnew: pointer;
begin
  if OldExprWord.NFunctionArg <> NewExprWord.NFunctionArg then
    raise
      Exception.Create('Cannot replace variable/function NFuntionArg doesn''t match');
  p := OldExprWord.AsPointer;
  pnew := NewExprWord.AsPointer;
  for i := 0 to Expressions.Count - 1 do
  begin
    Rec := PExpressionRec(Expressions.Objects[i]);
    repeat
      if (Rec.ExprWord = OldExprWord) then
      begin
        Rec.ExprWord := NewExprWord;
        Rec.Oper := NewExprWord.DoubleFunc;
      end;
      if p <> nil then
        for j := 0 to Rec.ExprWord.NFunctionArg - 1 do
          if Rec.Args[j] = p then
            Rec.Args[j] := pnew;
      rec := rec.next;
    until rec = nil;
  end
end;

procedure TExpressionParser.AddReplaceExprWord(AExprWord: TExprWord);
var
  IOldVar: Integer;
begin
  if WordsList.Search(Pchar(AExprWord.Name), IOldVar) then
  begin
    ReplaceExprWord(WordsList.Items[IOldVar], AExprWord);
    WordsList.AtFree(IOldVar);
    WordsList.Add(AExprWord);
  end
  else
    WordsList.Add(AExprWord);
end;

{ TCStyleParser }

procedure TCStyleParser.FillExpressList;
begin
  inherited;
  ReplaceFunction('!', TFunction.Create('fact', _factorial, 1));
  ReplaceFunction('div', TFunction.Create('div', _Div, 2));
  ReplaceFunction('%', TFunction.Create('perc', _Percentage, 1));
  ReplaceFunction('mod', TFunction.CreateOper('%', _mod, 2, True, 30));
  ReplaceFunction('or', TBooleanFunction.CreateOper('||', _or, 2, True, 70));
  ReplaceFunction('and', TBooleanFunction.CreateOper('&&', _or, 2, True, 70));
  ReplaceFunction(':=', TFunction.CreateOper('=', _Assign, 2, True, 200));
  ReplaceFunction('=', TBooleanFunction.CreateOper('==', _eq, 2, True, 50));
  ReplaceFunction('<>', TBooleanFunction.CreateOper('!=', _ne, 2, True, 50));
  ReplaceFunction('not', TBooleanFunction.CreateOper('!', _not, 1, True, 60));
end;

end.

