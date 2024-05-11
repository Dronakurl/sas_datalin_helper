%macro checkomat(inpdir=,inplib=,script=);
  /*
  * Detects, which columns in each table of the input library is used by script
  *
  * checkomat also looks for uninitialized variables as the following code runs without error 
  * data out;
  *   set inp;
  *   newvar = var_not_in_inp;
  * run;
  *
  * This would be a good option to test if the script is free of uninitialized variables
  * option varinitchk = error; 
  *
  * Parameters
  * ----------
  *
  * inpdir = directory containing the input tables
  * inplib = name of the library that is used in the script. Provide the name, the library does not have to be assigned.
  * script = Path of the script to be tested
  *
  * Output
  * ------
  *
  * dataset WORK.inpfields contains a list of tables, fields and column used is 1 for all variables used in script
  * */
    
  libname originp &inpdir.;
  libname &inplib. "~/tmp";
  option nonotes;

  /* Initialize fields to be tested */
  proc sql;
    create table inpfields as 
    select memname as table, name as field
    from dictionary.columns
    where libname = "ORIGINP";
  quit;

  data inpfields;
    set inpfields;
    tested = 0;
    used = 0;
  run;

  /* Check each field until finished */
  %let finished=no;
  %do %while (&finished ne yes);
    
    /* Copy the original data and overwrite if necessary */
    proc datasets lib=originp nolist;
      copy out=&inplib. force;
    run;
    quit;

    /* Get the next table and field to be tested */
    %let currentfield=;
    %let currenttable=;
    data _null_;
      set inpfields end=last;
      if tested=0 then do;
        call symput('currentfield', field);
        call symput('currenttable', table);
        if last then call symput('finished','yes');
        stop;
      end;
    run;

    %put Current Field: &currentfield;
    %put Current Table: &currenttable;

    /* Delete the field in the test library */
    proc sql;
    	alter table &inplib..&currenttable.
    	drop &currentfield;
    quit;

    /* Run the script to detect errors */

    proc printto log='~/tmp/tmp.log' new;
    run;
   	options notes;
	%include &script.;
    options nonotes;
    
	proc printto;
    run;
    
    /* Check the log file for errors */
	%let rc=0;
	data _null_;
	   infile '~/tmp/tmp.log';
	   input;
	   _infile_ = upcase(_infile_);
	   if index(_infile_, "ERROR:") > 0 or index(_infile_, "UNINITIALIZED")>0 then do;
	      put 'ERROR FOUND IN LOG: ' _infile_;
	      call symput("rc",1);
	   end;
	run;

    /* write result in inpfields*/
    data inpfields;
        set inpfields;
        if field="&currentfield." and table="&currenttable." then do;
          tested=1;
          %if &rc ne 0 %then %do;
            %put Field: %sysfunc(trim(&currenttable.))%sysfunc(trim(.&currentfield.)) is used!;
            used=1;
          %end;
          %else %do;
            %put Field: %sysfunc(trim(&currenttable.))%sysfunc(trim(.&currentfield.)) is not used!;
          %end;
        end;
    run;
    
  %end;

%mend;    


