/**-------------------------------------------------------------------------------------------**
** PROGRAM:    ADAE.SAS 
** CREATED:    December 2019
** PURPOSE:    CREATE ADVERSE EVENT DATASET FROM SDTM AE DATASET
** PROGRAMMER: Deepti Shah
** INPUT:      sdtmlib.ae, adsllib.adsl
** OUTPUT:     adsllib.adae
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */


/* ----------- Clear work library ----------- */

proc delete data=work._all_;
run;

/* Bring the SDTM AE dataset */

data ae;
	set sdtmlib.ae;
run;

/* sort the data by usubjid */

proc sort;
	by usubjid;
run;

/* Bring the ADSL dataset */

data adsl(keep= usubjid subjid siteid trt01p trt01pn age sex race saffl trtsdt trtstm trtsdtm trtedt trtetm trtedtm);
	set adsllib.adsl;
run;

proc sort;
	by usubjid;
run;

/* Merge ADSL AE and SDTM AE dataset */

data adae_1;
	merge ae(in=a) 
		  adsl (in=b);
	by usubjid;

	if a;
run;

/* Derive Analysis variables */

data adae_2;
	set adae_1;
	
	format astdt aendt is8601da.;
	format adurn is8601tm.;
	format asttm aentm arelsettm HHMM.;
	format astdtm aendtm  is8601dt.;
	
	/* Derive start and end date/times	*/

	astdt = input(aestdtc,is8601da.);
	asttm = input(substr(aestdtc,12),is8601tm.);
	astdtm = input(aestdtc,is8601dt.);

	aendt = input(aeendtc,is8601da.);
	aentm = input(substr(aeendtc,12),is8601tm.);
	aendtm = input(aeendtc,is8601dt.);

	/* Derive Relative Time to administration */

	astdy = astdt - trtsdt + 1;
	aendy = aendt - trtsdt + 1;
	adurn = aendtm - astdtm;


	/*	Derive analysis flags */

	if astdtm > trtsdtm then trtemfl = "Y";
	if aerel = "Possibly" or aerel = "Probably" or aerel = "Definitely" then anl01fl = "Y";

	
	/* Onset Time Relative to Prod */
	arelsettm = astdtm - trtsdtm;
	
run;



**-------------------------------------------------------------------------------**;
**          Create ADAE dataset with attributes                                **;
**-------------------------------------------------------------------------------**;

proc sql;

	create table adsllib.adae (label='Adverse Events') as
	select  studyid, 
			usubjid,
			subjid,
			siteid,
			aeseq,
			age,
			sex,
			race,
			saffl,
			trt01p,
			trt01pn,
			trtsdt,
			trtstm,
			trtsdtM,
			trtedt,
			trtetm,
			trtedtm,
			aeterm,
			aedecod,
			aeptcd,
			aebodsys,
			aebdsycd,
			aesoc,
			aesoccd,
			aesev,
			aeser,
			aeacn,
			aeacnoth,
			aerel,	
			aestdtc,
			astdt,
			asttm,
			astdtm,
			aendt,
			aentm,
			aendtm,
			astdy,
			aendy,
			adurn,
			trtemfl,
			anl01fl,
		    arelsettm	
	from adae_2;
	;
quit;

proc print;
run;

