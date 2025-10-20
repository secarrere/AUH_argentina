********************************************************************************
/*do-file: 1_data_append
********************************************************************************
********************************************************************************
****project title: AUH_argentina			
****database used: INDEC - Encuesta permanente de hogares (EPH)
****authors: S. Carrère	
********************************************************************************
********************************************************************************
****description: append raw data files from INDEC

****date: 20/11/2024	created
****date: 20/10/2025	modified
*/
********************************************************************************


cd "$AUH_argentina/data/default/EPH/"

/*******************************************************************************
********************************************************************************
STEP 1: data append
********************************************************************************
*******************************************************************************/

//Household files from 2003 to 2015

local i : dir "$AUH_argentina/data/default/EPH" files "Hogar_t*.dta"
foreach file in `i' {
use `file', clear

rename *, upper
egen HOGID_men = concat(CODUSU NRO_HOGAR),punct("_")
label variable HOGID_men "household id in housing"
order HOGID_men, b(ANO4)

//Merging cpi data into the dataset
merge m:1 ANO4 TRIMESTRE using "$AUH_argentina/data/cpi_data.dta"
label variable cpi "CPI value (base 100=IV.2018) author calculation from billion prices project data"
drop if _merge==2
drop _merge 

//Construction of deflated income per capita variable (base IV.2018)
gen IPCF_cpi=IPCF/cpi
label variable IPCF_cpi "Deflated IPCF (base=iv.2018)"

//Income groups with alternative definitions based on daily income per capita ($5.5-$11.5 ; $5.5-$13.5 ; $5.5-$15.5) = PPP $ Xvalue * 30 (days) * 14.23
//PPP factor conversion (PPP 2011 ajusted for 2018 ARG prices) = 14.23 (access december 2023, World bank)
gen catrev_511=1 if IPCF_cpi<2347.95 & IPCF_cpi!=. 
replace catrev_511=2 if IPCF_cpi>=2347.95 & IPCF_cpi<4909.35 
replace catrev_511=3 if IPCF_cpi>=4909.35
label define catrev_class 1"Poor" 2"Vulnerable" 3"Middle and upper-income groups",replace
label values catrev_511 catrev_class
label variable catrev_511 "Income groups based on income per capita per day, $5.5;$11.5 (2011 $US PPP in 2018; factor conv = 14.23)"

gen catrev_513=1 if IPCF_cpi<2347.95 & IPCF_cpi!=. 
replace catrev_513=2 if IPCF_cpi>=2347.95 & IPCF_cpi<5763.15 
replace catrev_513=3 if IPCF_cpi>=5763.15 
label values catrev_513 catrev_class
label variable catrev_513 "Income groups based on income per capita per day, $5.5;$13.5 (2011 $US PPP in 2018; factor conv = 14.23)"

gen catrev_515=1 if IPCF_cpi<2347.95 & IPCF_cpi!=. 
replace catrev_515=2 if IPCF_cpi>=2347.95 & IPCF_cpi<6616.95 
replace catrev_515=3 if IPCF_cpi>=6616.95 
label values catrev_515 catrev_class
label variable catrev_515 "Income groups based on income per capita per day, $5.5;$15.5 (2011 $US PPP in 2018; factor conv = 14.23)"


cd "$AUH_argentina/data"
save `file'.,replace
cd "$AUH_argentina/data/default/EPH/"
}


//Append household level files
clear
cd "$AUH_argentina/data"
local fhog_name : dir "$AUH_argentina/data" files "hogar_t*"
foreach file of local fhog_name{
        append using "`file'"
        }
save basehog_2003_2015.dta, replace		

clear

//Individual files from 2003 to 2015
cd "$AUH_argentina/data/default/EPH"

local i : dir "$AUH_argentina/data/default/EPH/" files "Individual_t*.dta"
foreach file in `i' {
use `file', clear

rename *, upper

// Individual ID
egen HOGID_ind = concat(CODUSU NRO_HOGAR COMPONENTE),punct("_")
label variable HOGID_ind "Person id in a hh"
order HOGID_ind, b(ANO4)

// Household ID
egen HOGID_men = concat(CODUSU NRO_HOGAR),punct("_")
label variable HOGID_men "Household id in a house"
order HOGID_men, b(HOGID_ind)


**

cd "$AUH_argentina/data"
save `file',replace
cd "$AUH_argentina/data/default/EPH/"
}

clear

//Merging individual level files
cd "$AUH_argentina/data"
local find_name : dir "$AUH_argentina/data" files "individual_t*"
foreach file of local find_name{
        append using "`file'"
        }	

save baseind_2003_2015.dta, replace

