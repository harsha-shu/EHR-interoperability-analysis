
SELECT ------------------(who is impacted)
    p.id as Patient_ID,
    p.birthdate as Patient_DOB,
    p.gender as Patient_Gender,
    P.race as Patient_Race,
    e.id as Encounter_ID, ----(where did it happen)
    e.encounterclass as Encounter_Class,-------(i.e inpatient,outpatient,ambulatory)
    c.start as Diagnosis_Date,-----------(what was the condition recordings)
    c.description as Clinical_Condition,
    CMS_Map.Mapped_ICD10_Code, ----------(did the system work?) -- ADDED COMMA HERE

    CASE 
        WHEN CMS_Map.Mapped_ICD10_Code is null THEN 'Failed Exchange (Gap)' 
        ELSE 'Successful Exchange'
    END as Interoperability_status 

FROM conditions c
JOIN patients p 
    ON c.PATIENT = p.Id
JOIN encounters e
    ON c.ENCOUNTER = e.Id
LEFT JOIN 
    ( SELECT 
        c1.concept_code as SNOMED_Code,
        c2.concept_code as Mapped_ICD10_Code
      FROM 
        omop_concept c1
      INNER JOIN 
        omop_relationship r 
            ON c1.concept_id = r.concept_id_2
            AND r.relationship_id = 'Maps to'
      INNER JOIN
        omop_concept c2
            ON r.concept_id_1 = c2.concept_id
            AND c2.vocabulary_id = 'ICD10CM'
      WHERE c1.vocabulary_id = 'SNOMED'
    ) CMS_Map 
    ON CMS_Map.SNOMED_Code = CAST(c.code as nvarchar(50));