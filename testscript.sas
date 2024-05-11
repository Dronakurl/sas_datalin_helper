/*
Script for testing that mocks a data transformation script
that uses the test tables created by "create_input.sas"

The check-o-mat is expected to detect, that test1.x is used and test2.a.

The libnames need to be set outside the script

libname inp (testin);
libname out "~/out";
*/


data out.x;
	set inp.test1;
	g=x;
run;

proc sql;
	create table out.y as
	select *
	from test2
	where a=12;
run;
