program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils;

type

  TArrNameVariable=array[1..250] of string;
  TArrSumVariable=array[1..250] of integer;

var
   f: textfile;
   line,Token: string;
   Current: integer;

 procedure CreateClearFile();
   var
   fIn,fOut: textfile;
   current: integer;
   line:string;
   quotes,oneLineComment,ManyLineComment,quote: boolean;

   begin
   assign(fIn,'php.txt');
   reset(fIn);
   assign(fOut,'phpClear.txt');
   rewrite(fOut);

   quotes:=false;
   ManyLineComment:=false;
   quote:=false;
   while not Eof(fIn) do
     begin
     readln(fIn,line);
     current:=1;
     oneLineComment:=false;
     while (current<=length(line)) do
         begin

         if quotes then
            begin
            if line[current]='"' then quotes:=false;
            delete(line,current,1);
            current:=current-1;
            if line='' then break;
            end;

         if quote then
            begin
            if line[current]=#39 then quote:=false;
            delete(line,current,1);
            current:=current-1;
            if line='' then break;
            end;

         if ManyLineComment then
          begin
          if (line[current]='*') and (line[current+1]='/')
          then
            begin
            ManyLineComment:=false;
            delete(line,current,1);
            end;
          delete(line,current,1);
          current:=current-1;
          if line='' then break;
          end;

         if oneLineComment then
            begin
            delete(line,current,length(line)-current+1);
            end;

         if not (oneLineComment or quotes or ManyLineComment or quotes) then
            begin
            if (line[current]='{') or (line[current]='}') or (line[current]='(') then
              begin
              writeln(fOut,copy(line,1,current-1));
              writeln(fOut,copy(line,current,1));
              delete(line,1,current);
              current:=1;
              if line='' then break;
              end;

            if line[current]='"' then
              begin
              delete(line,current,1);
              current:=current-1;
              quotes:=true;
              end;

            if line[current]=#39 then
              begin
              delete(line,current,1);
              current:=current-1;
              quote:=true;
              end;

            if (line[current]='#') then
              begin
              current:=current-1;
              oneLineComment:=true;
              end;

            if ((line[current]='/') and (line[current+1]='/')) then
              begin
              current:=current-2;
              oneLineComment:=true;
              end;

            if (line[current]='*') and (line[current-1]='/') then
              begin
              current:=current-2;
              ManyLineComment:=true;
              end

            end;
         current:=current+1;
         end;
     writeln(fOut,line);
     end;
   close(fOut);
   close(fIn);
   end;

 function FindToken(var crr: integer; const line:string): string;
   begin
    result:='';
    while ((line[crr]=' ') or (line[crr]='(') or (line[crr]=')')
    or (line[crr]=',') or (line[crr]=';')) and (crr<=length(line)) do crr:=crr+1;
    while (line[crr]<>' ') and (line[crr]<>'(') and (line[crr]<>')')
    and (line[crr]<>',') and (line[crr]<>';') and (crr<=length(line)) do
      begin
      result:=result+line[crr];
      crr:=crr+1;
      end;
   end;

  procedure includeInArrayVariable(NameVariable: string;var Number: integer; var ArrayVariable:TarrNameVariable);
    begin
    Number:=Number+1;
    ArrayVariable[Number]:=NameVariable;
    end;

  function FindVariable(const Variable:string;
  const ArrayVariable: TarrNameVariable;
  const numberVariable:integer; var ArraySumVariable:TArrSumVariable):boolean;
  var
  i: integer;
   begin
   result:=false;

   for i:=1 to numberVariable do
    if Variable=ArrayVariable[i] then
      begin
      result:=true;
      ArraySumVariable[i]:=ArraySumVariable[i]+1;
      break;
      end;
   end;


  procedure Variable(const NameFunction:string);
  var
  ArrayNameVariable:TArrNameVariable;
  ArraySumVariable:TArrSumVariable;

  functionFlag:boolean;
  numberVariable,level,i:integer;
  nameSubFunction:string;

    begin
    numberVariable:=0;
    functionFlag:=true;
    level:=0;
    for i:=1 to 250 do ArraySumVariable[i]:=0;

    while not Eof(F) do
     begin
     readln(f,line);
     Trim(line);
     Current:=1;
     while (Current <= Length(line)) do
       begin
       Token:=FindToken(current,line);
       if Token<>'' then
        begin
        if token='function' then
          begin
          nameSubFunction:='';
          while nameSubFunction='' do nameSubFunction:=FindToken(current,line);
          Variable(nameSubFunction);
          level:=level+1;
          end;
        if (Token[1]='$') then
          if (not FindVariable(Token,ArrayNameVariable,numberVariable,ArraySumVariable))
            then includeInArrayVariable(Token,numberVariable,ArrayNameVariable);
        if ((token='{') and (not functionFlag)) then level:=level+1;
        if (token='}') or (token='?>') then level:=level-1;
        if ((level=0) and (not functionFlag)) then
          begin
          writeln(NameFunction,':');
          for i:=1 to numberVariable do writeln(ArrayNameVariable[i],'=',ArraySumVariable[i]);
          writeln('end ', NameFunction);
          writeln;
          exit;
          end;
        if (((token='{') or (token='<?php')) and functionFlag) then
          begin
          functionFlag:=false;
          level:=level+1;
          end;
        end;
       end;
     Current:=1;
     end;

    end;


begin
   CreateClearFile();

   assign(f,'phpClear.txt');
   reset(f);

   Variable('Main');

   close(f);

   readln;
end.
