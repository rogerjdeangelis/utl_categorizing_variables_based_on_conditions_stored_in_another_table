Categorizing variables based on conditions stored in another table

 Apply code located in a table to each observation of another table

see
https://goo.gl/aKiuna
https://stackoverflow.com/questions/48583255/categorizing-variables-based-on-conditions-stored-in-another-table-sas

INPUT
======

 ALGORITHM (Apply to each observation)

 Apply this code located in a table to each observation of another table

     case
      when (Var1<20 ) then 1
      when (40>Var1>=20 ) then 2
      when (Var1>=40 ) then 3
      else . end as Var1

     ,case
      when (Var2<0.2 ) then 1
      when (Var2>=0.2 ) then 2
      else . end as Var2
   from
      have


 WORK.META total obs=5

    VARIABLE    CONDITION      CATEGORY

      Var1      Var1<20            1
      Var1      40>Var1>=20        2
      Var1      Var1>=40           3

      Var2      Var2<0.2           1
      Var2      Var2>=0.2          2

 WORK.HAVE obs=3  |  RULES (apply the code below)
                  |
      VAR1    VAR2  |                                             VAR1    VAR2
                    |
       19      0.2  | var1<20 then var1=1  var2=>.2 then var2=2     1       2
       30      0.1  | ...                                           2       1
       45      0.2  | var1>=40 then var1=3 var2=>.2 then var2=2     3       2


PROCESS ( All the code)
=======================

      * just in case objects exist;
      %symdel code1 code2 / nowarn;

      proc datasets lib=work;
      delete want;
      run;quit;

      data _null_;

        if _n_=0 then do;
           %let rc=%sysfunc(dosubl('
               data _null_;
                 retain code ;
                 length code $32576 cmd $200 sfx $1;

                 set meta end=eof;
                 by variable ;

                 sfx=substr(variable,4);

                 cmd=catx(" ", "when (", condition, ") then ", category) ;
                 code=catx(" ",code,cmd);

                 if last.variable then do;
                    code=catx(" ",code," else . end as", variable);
                    call symputx("code"!!sfx,code);
                    code="";
                 end;
              run;quit;
           '));
        end;

        rc=dosubl('
           proc sql;
              create
                table want as
              select
                case
                  &code1
               ,case
                  &code2
              from
                have
          ;quit;
        ');

         stop;
      run;quit;


     %put &=code1;
     %put &=code2;

OUTPUT
=====

 WORK.WANT total obs=3

   VAR1    VAR2

     1       2
     2       1
     3       2

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data meta ;
 informat variable $32. condition$200. ;
 input variable :$32. condition :$200. category ;
cards;
Var1 Var1<20 1
Var1 40>Var1>=20 2
Var1 Var1>=40 3
Var2 Var2<0.2 1
Var2 Var2>=0.2 2
;;;;
run;quit;

data have ;
 input Var1 Var2;
cards4;
19 0.2
30 0.1
45 0.2
;;;;
run;quit;


%put &=code1;
%put &=code2;
*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

 * just in case objects exist;
 %symdel code1 code2 / nowarn;

 proc datasets lib=work;
 delete want;
 run;quit;

 data _null_;

   if _n_=0 then do;
      %let rc=%sysfunc(dosubl('
          data _null_;
            retain code ;
            length code $32576 cmd $200 sfx $1;

            set meta end=eof;
            by variable ;

            sfx=substr(variable,4);

            cmd=catx(" ", "when (", condition, ") then ", category) ;
            code=catx(" ",code,cmd);

            if last.variable then do;
               code=catx(" ",code," else . end as", variable);
               call symputx("code"!!sfx,code);
               code="";
            end;
         run;quit;
      '));
   end;

   rc=dosubl('
      proc sql;
         create
           table want as
         select
           case
             &code1
          ,case
             &code2
         from
           have
     ;quit;
   ');

    stop;
 run;quit;


%put &=code1;
%put &=code2;

