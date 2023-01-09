libname coreData xmlv2 'C:\Users\ETiffany\OneDrive - State of Indiana\Desktop\coreInterviewFiles.XML';

proc sql;
title 'Seed Count';
select count(*) from coredata.Interview
where ISEED=1 and CONSENTA=1;

proc sql;
title 'Nonseed Count';
select count(*) from coredata.Interview
where ISEED=0 and CONSENTA=1;

proc sql;
title 'HIV Consent Count';
select count(*) from coredata.Interview
where CONSENTA=1 and CONSENTB=1;

proc sql;
title 'HCV Consent Count';
select count(*) from coredata.Interview
where CONSENTA=1 and CNSTHEP1=1;