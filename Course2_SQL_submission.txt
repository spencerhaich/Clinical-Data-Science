WITH person1 as (select distinct md.subject_id from mimic3_demo.DIAGNOSES_ICD md),
     person2 as (select distinct p1.subject_id, md.HADM_ID 
		 from person1 p1 join mimic3_demo.DIAGNOSES_ICD md on p1.subject_id = md.subject_id),
     person as (select distinct p2.subject_id, p2.HADM_ID, md.ICD9_CODE
                  from person2 p2 join mimic3_demo.DIAGNOSES_ICD md on p2.subject_id = md.subject_id)
SELECT COUNT(DISTINCT subject_id) as T_SUBJECT_ID, COUNT(DISTINCT HADM_ID) as T_HADM_ID, COUNT(DISTINCT ICD9_CODE) as T_ICD9_CODE
    FROM person