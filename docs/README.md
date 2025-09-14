# SAS Data Cleaning & Analysis Project

## 📌 Project Overview
This project demonstrates end-to-end data cleaning, transformation, and analysis using **Base SAS**.  
It simulates a real-world healthcare scenario with **patient demographics** and **encounter/visit-level data**.

The workflow follows industry practices: **traceability, minimal overwriting, use of flags, and transparent derivations**.

---

## 📂 Datasets
- **patients_raw.csv** → Contains patient demographic data (ID, DOB, Sex, Phone, City).  
- **encounters_raw.csv** → Contains encounter-level data (Patient ID, Visit Date, Department, Charges, Status).  

---

## 🔧 Steps Performed
1. **Data Import** (PROC IMPORT for raw CSVs).  
2. **Cleaning & Standardization**  
   - Patient IDs standardized (P###).  
   - Dates standardized to SAS DATE9 format.  
   - Sex standardized to M/F/U.  
   - Phone numbers cleaned to last 10 digits.  
   - Cities standardized to consistent naming.  
   - Charges converted to numeric.  
   - Status standardized (Yes/No/Completed/Cancelled).  
3. **Merging** of patient and encounter datasets by Patient ID.  
4. **Derivations**  
   - Age = difference between Visit Date and DOB.  
   - PaidFlag = 1 (Yes/Completed), 0 (No/Cancelled).  
5. **Analysis**  
   - Frequency of Department × Sex.  
   - Summary stats of Charges by Department.  
   - Frequency distribution of PaidFlag.  

---

## 📊 Outputs
- `patients_final.csv` → Cleaned patient-level data.  
- `encounters_final.csv` → Cleaned encounter-level data.  
- `merge_visits.csv` → Merged dataset with derived variables.  
- SAS Results: Frequency tables and summary statistics.  

---

## 🛠️ Tools Used
- **SAS 9.4 (Base SAS, DATA Step, PROC FREQ, PROC MEANS, PROC EXPORT)**  

---

## 👤 Author
**Muzakkir Ansari**  
B.Sc. Statistics, 2024 | Mumbai, India  
📧 muzakkiransari001@gmail.com

