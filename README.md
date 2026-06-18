# Copper Production Downtime Analysis

This project analyzes downtime and failure data from a copper cable production process. 
Using SQL and Power BI, I examined machine performance, operator performance, shift performance, failure types, and downtime trends to determine where the majority of downtime originated.

---

## Business Questions & Answers:

- **Which machines contribute the most downtime?**
  
There are a total of 17 Machines.
Machine 8 and 2 make up for 48% of all downtime incidents.

- **Which operators and shifts experience the highest number of failures?**
  
The top 5 Operators that might need additonal training are: 13, 31, 14, 7 and 6.
Although shift A shows more downtime (7525 minutes) than shift B (7150 minutes), the results aren't too discrepant. As we don't have a full panorama of the Copper Company, this could also be due to more activity and personel during the first shift.

- **Are Cable Failures or Other Failures responsible for most downtime?**
  
Cable Failures make up for the most failures and downtime records.

- **Is downtime increasing or decreasing over time?**
  
It seems that there is a drift in the process and possible systemic degradation resulting in increased downtime by day.

- **Which areas should be prioritized for process improvement?**
  
The efforts should be spent on Cable related failures as they make up for the most downtime.
Prioritize inspection and maintenance on problematic machines, assuming they are not getting more workload compared to the others - in that cases also consider distributing the workload more efficiently.
Assess what Other Failures consist of: there might be another dominant cause that could be easily tackled and significantly improve productivity.
Implement a compact workshop on best manufacturing practices for Operators.
Keep monitoring data and check if the slope reduces.

---

## Dataset

The dataset contains production records with the following information:

- Machine
- Shift
- Operator
- Production Date
- Cable Failures
- Cable Failure Downtime
- Other Failures
- Other Failure Downtime


### Tools Used:
- SQL (MySQL)
- Power BI
- Lean Six Sigma Analysis Techniques
- Exploratory Data Analysis
- KPI Summary

### Calculated:
- Total Failures
- Total Downtime
- Average Downtime per Failure
- Number of Machines
- Number of Operators
- Machine Performance Analysis
- Pareto Analysis
- Cumulative Percentage
- Time Trends


### Skills Demonstrated:
- SQL Querying
- Data Aggregation
- KPI Development
- Pareto Analysis
- Process Improvement Analysis
- Data Visualization
- Power BI Dashboard Design
- Operations Analytics
- Lean Six Sigma Concepts
