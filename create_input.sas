/*
	Script to create input for testing
	This is to be used to for testscript.sas
*/
libname testin "~/testinput";

data testin.test1;
	x=1; y=2; output;
	x=1; y=2; output;
	x=1; y=2; output;
run;

data testin.test2;
	a=1; b=3; output;
	a=1; b=3; output;
	a=1; b=3; output;
	a=1; b=3; output;
run;
