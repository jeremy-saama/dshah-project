/**-------------------------------------------------------------------------------------------**
** PROGRAM:    EX.SAS
** CREATED:    November 2019
** PURPOSE:    Create SDTM - EX dataset from Raw input data.
** PROGRAMMER: Deepti Shah
** INPUT:	   rawlib.exposure
** OUTPUT:	   sdtm.ex
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */



data ex_e1;
	
	 length studyid $8
        	domain $4
            usubjid $20
            exseq $2
            extrt $200
			excat $100
			exdosu $10
 			exdosfrm $20 
			exdosfrq $30
            exroute $30 
            epoch $30
            exstdtc $12
            exendtc $12
            exstdy $15
            exendy $15            
            ;

	set rawlib.exposure;
	
	
    studyid = proto;
    domain = 'EX';
    usubjid = strip(proto) || '-' || put(inv_no,z2.) || '-' || put(patid,z3.);
    exseq = strip(seq);
    
    if strip(cohort) = 1 then extrt = 'Cohort 1';
    else if strip(cohort) = 2 then extrt = 'Cohort 2';
    else extrt = "";
    
	excat = strip(mode);
	exdose =  proddose;
    exdosu 		= "mg";
 	exdosfrm	= "SUSPENSION";	 
	exdosfrq	= "Every 4 minutes";
 	exroute		= "Intravenous"; 
	epoch		= period;
	exstdy		= "Study Day 1";
	exendy		= "Study Day 1";
	
	
    keep studyid domain usubjid exseq extrt excat exdose exdosu exdosfrq epoch exstdy exdosfrm exroute exendy;
	
 	        
run;

 
/* ----------- Set the treatment start date and end date  ----------- */

data dm_treat(keep=usubjid exstdtc exendtc);
	set sdtmlib.dm;

	exstdtc = rfstdtc;
	exendtc = rfendtc; 
	
run;

/* ----------- Sort the treatment data by usubjid ----------- */

proc sort data=dm_treat;
	by usubjid;
run;
 

proc sort data=ex_e1;
	by usubjid;
run;

/* ----------- merge the data ----------- */

data ex;
	merge ex_e1 (in= ex_1) dm_treat;
	by usubjid;
	if ex_1;
run;




**-------------------------------------------------------------------------------**;
**          Create Final EX dataset with all the key variable                    **;
**			Use Proc SQL - Create Table statement to create final EX dataset	 **;
**-------------------------------------------------------------------------------**;

proc sql;

	create table sdtmlib.ex (label='Exposure') as
	select  studyid, 
			domain,
			usubjid,
			exseq,
			extrt,
			excat,
			exdose,
			exdosu,
 			exdosfrm, 
			exdosfrq,
 			exroute, 
			epoch,
			exstdtc,
			exendtc,
			exstdy,
			exendy
		       
	from ex
	;
quit;

proc print;
run;


 
