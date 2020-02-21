/**-------------------------------------------------------------------------------------------**
** PROGRAM:    AE.SAS
** CREATED:    November 2019
** PURPOSE:    Create SDTM - AE dataset from Raw input data.
** PROGRAMMER: Deepti Shah
** INPUT:	   rawlib.ae
** OUTPUT:	   sdtm.ae
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */



data ae_a1;
	
	 length studyid $8 
        	domain $4
            usubjid $20
            aeseq $2
            aeterm $200
            aedecod $100
            aebodsys $200
            aesev $15
            aeser $1
            aeacn $100
            aeacnoth $100
            aerel $27
            aestdtc $19
            aeendtc $19
            aesoc $100
            aesoccd $8
            aeptcd $5
            
            
            ;

	set rawlib.ae;
	where ( missing(aeanycd) <> 0 or aeterm <> "" ); 
	
    studyid = proto;
    domain = 'AE';
    usubjid = strip(proto) || '-' || put(inv_no,z2.) || '-' || put(patid,z3.);
    aeseq = strip(seq);
    aeterm = upcase(strip(aeterm));
    
    /* ----------- convert and concatenate the date and time fields  ----------- */
   
    aestdt_temp =  	STRIP(PUT(YEAR(aestdt),4.)) || '-' || STRIP(PUT(MONTH(aestdt),Z2.)) || '-' || STRIP(PUT(DAY(aestdt),Z2.)) ;    
    aesttm_temp = 	put(aesttm,TOD5.);	
	aestdtc = aestdt_temp || "T" || aesttm_temp;

    aeendt_temp =  	STRIP(PUT(YEAR(aeendt),4.)) || '-' || STRIP(PUT(MONTH(aeendt),Z2.)) || '-' || STRIP(PUT(DAY(aeendt),Z2.)) ;    
    aeentm_temp = 	put(aeentm,TOD5.);	
	aeendtc = aeendt_temp || "T" || aeentm_temp;	
	
	aedecod = upcase(aedecod);
	
	if aerelcd = 1 then aerel = "UNRELATED";
	else if aerelcd = 2 then aerel = "POSSIBLY";
	else if aerelcd = 3 then aerel = "PROBABLY";
	else if aerelcd = 4 then aerel = "DEFINITELY";
	else aerel = "";
	
	if aesevcd = 1 then aesev = "MILD";
	else if aesevcd = 2 then aesev = "MOEDERATE";
	else if aesevcd = 3 then aesev = "SEVERE";
	else if aesevcd = 4 then aesev = "LIFE-THREATENING";
	else aesev = "";
	
	if aesercd = 4 then aeser = 'Y';
	else aeser = 'N';

	if aenoatcd=0 then aeacn = "DOSE NOT CHANGED";
	else if aetxcd=1 then aeacn = "NOT APPLICABLE";
	else if aeprencd=2 then aeacn = "DRUG WITHDRAWN";
	else if aedccd=3 then aeacn = "DRUG WITHDRAWN";
	else if aesercd=4 then aeacn = "NOT APPLICABLE";
	else aeacn = "";
	
	if aetxcd=1 then aeacnoth = "TREATMENT";
	else if aedccd=3 then aeacnoth = "DISCONTINUED TRIAL";
	else if aesercd=4 then aeacnoth = "SAE REPORTED";
	else aeacnoth = "";
	
		
    aeptcd = aeprefcd;
    aebodsys = aesoc;
    aebdsycd = aesoccd;
	
	
	aesoc = strip(aesoc);
    aesoccd = strip(aesoccd);
    
    keep studyid domain usubjid aeseq aeterm aestdtc aeendtc aerel aesoc aesoccd aedecod aeacn aeacnoth aesevcd aesev aeser aeptcd aebodsys aebdsycd;
	
 	        
run;

 





**-------------------------------------------------------------------------------**;
**          Create Final AE dataset with all the key variable                    **;
**			Use Proc SQL - Create Table statement to create final AE dataset	 **;
**-------------------------------------------------------------------------------**;

proc sql;

    create table sdtmlib.ae(label = "Adverse Events") as
    
   
        select  studyid, 
			    domain,
			    usubjid, 
			    aeseq,
			    aeterm,
			    aestdtc, 
			    aeendtc, 
			    aerel, 
			    aesoc, 
			    aesoccd, 
			    aedecod, 
			    aeacn, 
			    aeacnoth, 
			    aesevcd, 
			    aesev, 
			    aeser, 
			    aeptcd, 
			    aebodsys, 
			    aebdsycd
        from ae_a1;
quit;

proc print;
run;
