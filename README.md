MySQL Data Cleaning Project: World Layoffs
Project Objective
In this project, I implemented an end-to-end SQL cleaning process to make raw layoff data retrieved from Kaggle analyzable.

Actions Performed
Staging: Working tables were created to preserve the raw data.

Remove Duplicates: Duplicate records were detected and cleaned using the ROW_NUMBER() function.

Standardization: Spelling errors in industry names (Crypto, etc.) and country names were corrected. TRIM() and TRAILING were used.

Date Conversion: Dates of type TEXT were converted to actual DATE format using STR_TO_DATE.

Handling Nulls: Missing data (Industry) was completed using the Self-Join method from other records of the same company.

Data Removal: Rows and auxiliary columns that were worthless for analysis (containing null values) were deleted.

Technologies Used
MySQL Workbench
SQL Window Functions 
Data Imputation techniques
