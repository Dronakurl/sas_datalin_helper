# SAS data lineage helper

## Purpose 

This is a SAS helper script that runs a given data analysis or ETL script and detects, which tables and fields it uses. This is useful when you want to ensure data lineage or just remove unnecessary data dependencies from your workflow.

Ideally, one would write scripts for analysis or ETL using only the data required for that purpose. In reality, scripts evolve over time and some tables or fields are no longer needed, but still included in the input library.

## How it works

The macro `checkomat.sas` repeatedly runs the input script using a copied input dataset where one specific data field is removed from the input data set. It then detects, if there are errors or certain notes in the log that indicate that a field is required by the script.

### Example call of the script

```sas
%checkomat(inpdir="~/testinput",inplib=inp,script="~/testscript.sas");
```

### Parameters

- `inpdir` = directory containing the input tables
- `inplib` = name of the library that is used in the script. Provide the name, the library does not have to be assigned.
- `script` = Path of the script to be tested

### Output

Dataset `WORK.inpfields` contains a list of tables, fields and column used is 1 for all variables used in script

## Limitations

- Script only detects, which data fields are used in one given input directory
- Does not work, if used data fields change randomly or triggered by external data (not in given input directory)
- Script must not change the log options as the checkomat script depends on the proper log output
- Script always copies and uses the full input data set, so it is not suitable for large input datasets
