use teamproject3;
##Analyse des Salaires et de l'Expérience
WITH SalaryStats AS (
    SELECT
        JobTitle,
        EducationLevel,
        AVG(Salary) AS AverageSalary,
        MIN(Salary) AS MinSalary,
        MAX(Salary) AS MaxSalary,
        COUNT(*) AS EmployeeCount
    FROM
        EmployeeData
    GROUP BY
        JobTitle, EducationLevel
),
RankedSalaries AS (
    SELECT
        JobTitle,
        EducationLevel,
        AverageSalary,
        MinSalary,
        MaxSalary,
        EmployeeCount,
        RANK() OVER (PARTITION BY EducationLevel ORDER BY AverageSalary DESC) AS SalaryRank,
        NTILE(4) OVER (PARTITION BY EducationLevel ORDER BY AverageSalary) AS SalaryQuartile
    FROM
        SalaryStats
),
ExperienceStats AS (
    SELECT
        JobTitle,
        EducationLevel,
        AVG(YearsOfExperience) AS AverageExperience
    FROM
        EmployeeData
    GROUP BY
        JobTitle, EducationLevel
)
SELECT
    rs.JobTitle,
    rs.EducationLevel,
    rs.AverageSalary,
    rs.MinSalary,
    rs.MaxSalary,
    rs.EmployeeCount,
    rs.SalaryRank,
    rs.SalaryQuartile,
    es.AverageExperience
FROM
    RankedSalaries rs
JOIN
    ExperienceStats es ON rs.JobTitle = es.JobTitle AND rs.EducationLevel = es.EducationLevel
WHERE
    rs.EmployeeCount > 5 -- Exclure les postes avec peu d'employés
ORDER BY
    rs.EducationLevel, rs.SalaryRank;
    WITH AgeCategories AS (
    SELECT
        CASE
            WHEN Age < 25 THEN '18-24'
            WHEN Age BETWEEN 25 AND 34 THEN '25-34'
            WHEN Age BETWEEN 35 AND 44 THEN '35-44'
            WHEN Age BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS AgeGroup,
        Gender,
        AVG(Salary) AS AverageSalary,
        COUNT(*) AS EmployeeCount
    FROM
        EmployeeData
    GROUP BY
        AgeGroup, Gender
),
SalaryVariance AS (
    SELECT
        AgeGroup,
        Gender,
        AverageSalary,
        EmployeeCount,
        MAX(AverageSalary) OVER (PARTITION BY AgeGroup) - MIN(AverageSalary) OVER (PARTITION BY AgeGroup) AS SalaryRange
    FROM
        AgeCategories
)
SELECT
    AgeGroup,
    Gender,
    AverageSalary,
    EmployeeCount,
    SalaryRange
FROM
    SalaryVariance
WHERE
    EmployeeCount > 3 -- Exclure les catégories avec peu d'employés
ORDER BY
    AgeGroup, Gender;
   #AgeGroupInsights
-- #25-34 Age Group:
-- #Females: Average Salary is approximately $53,231 with 130 employees in this group.
-- #The salary range is around $6,086, indicating a moderate salary disparity among employees.
-- #Males: Average Salary is approximately $59,317 with 160 employees.
-- #Similar to females, the salary range is also $6,086.
-- #Analysis: There’s a noticeable gap in average salary, with males earning about $6,086 more than females.
-- #This disparity, despite a similar salary range, could prompt the organization to evaluate its compensation policies for gender equity.
-- #35-44 Age Group:
-- #Females: Average Salary is about $107,798 with 168 employees.
-- #The salary range is narrower at $5,536, suggesting more uniformity in salaries within this group.
-- #Males: Average Salary is approximately $113,333 with 132 employees.
-- #The salary range is also $5,536.
-- #Analysis: The gap here narrows to about $5,535, indicating progress toward parity,
-- #but it still highlights the need for ongoing attention to gender pay equity.
-- #45-54 Age Group:
-- #Females: Average Salary stands at $166,034 with 58 employees, and the salary range is quite small at $1,731.
-- #Males: Average Salary is approximately $167,766 with 94 employees, also exhibiting a low salary range of $1,731.
-- #Analysis: The gap is minimal at about $1,732, showing that the organization may be achieving closer pay equality in this age group.
-- #However, the smaller employee count for females may warrant investigation into retention strategies or potential biases in promotion opportunities.
-- #OverallObservations
-- #Salary Progression: As employees age, average salaries increase significantly, particularly for the 35-44 and 45-54 age groups.
-- #This trend suggests that experience is rewarded, but the gender pay gap remains a consistent issue.
-- #Employee Count: The larger number of employees in the 25-34 age group compared to the 45-54 group indicates potential turnover or a pipeline issue.
-- #Retaining talent as employees age and gain experience may need to be a focus for the company.
-- #StrategicRecommendations:
-- #Addressing Pay Gaps: It would be beneficial for the organization to conduct a thorough review of salary structures
-- #and adjust where necessary to ensure fair compensation across genders and age groups.
-- #Targeted Programs: Implement mentorship and career development programs aimed at females,
-- #especially in the younger age groups, to encourage retention and advancement.
-- #Regular Reviews: Establish a regular review process to monitor salary distributions
-- #and ensure ongoing equity in compensation practices.