-- Get the last 30 days of failed Analytics staging and transform jobs.

SELECT  JobId, JobSource, FORMAT(StartTime, 'MM/dd/yyyy HH:mm:ss') AS StartTime, FORMAT(EndTime, 'MM/dd/yyyy HH:mm:ss') AS EndTime, Result, ResultMessage
FROM    dbo.tbl_JobHistory
WHERE   Result != 0
    AND StartTime > DATEADD(DAY, -30, GETDATE())
    AND 
    (
           JobId = '183cd78d-1eeb-4b80-a488-cdd823b51c40'    -- Work Item Link Types Analytics Job (Recovery)
        OR JobId = '18ff999a-382f-4573-8f18-6ea3e7d72355'    -- Team Setting Analytics Job
        OR JobId = '1eb33c0e-ba17-4571-8ead-73fba82b7083'    -- Collection Analytics Job
        OR JobId = '266c0520-bc58-4f37-855a-0b095c00ba9e'    -- Test Configuration Sync Analytics Job
        OR JobId = '327ea60c-2ede-4d49-b87c-967c2b04c950'    -- Work Item Revisions Analytics Job
        OR JobId = '3e267d39-c3d0-402c-9312-8a0eb09cc9e5'    -- Project Analytics Job
        OR JobId = '422eaa92-8df9-44dd-8590-accd1d8c496e'    -- Kanban Board Rows Analytics Job
        OR JobId = '439ff596-d92b-44c0-a1f4-f97277502fd7'    -- Test Case Reference Sync Analytics Job
        OR JobId = '44175be3-dd88-403b-a88b-cd11863423bc'    -- WorkItem Iteration Analytics Job
        OR JobId = '4945fd20-dfd1-4456-b36f-935d8caa3cb1'    -- Tags Analytics Job
        OR JobId = '53bd3fb1-5419-448a-a46b-3a1281b920ef'    -- Kanban Board Columns Analytics Job
        OR JobId = '58ceeb48-b7f2-469a-9854-ede85a60ab8d'    -- Kanban Board Rows Analytics Job (Recovery)
        OR JobId = '67430e02-acdf-4103-b6fc-38602cdc862c'    -- Project Analytics Job (Recovery)
        OR JobId = '68ef493a-3540-4fc1-8d9b-5dd28763497d'    -- Kanban Board Columns Analytics Job (Recovery)
        OR JobId = '74b395d4-4d86-40b6-901d-830cf7963de3'    -- Work Item Destroyed Analytics Job
        OR JobId = '78054eb1-62db-46fa-9704-e35f17c16079'    -- Test Suite Sync Analytics Job
        OR JobId = '7c4627d1-2fdf-4ddb-8172-a831ca134cc3'    -- Work Item Destroyed Analytics Job (Recovery)
        OR JobId = '843a6142-6e52-47d7-8711-4a9d2616fce2'    -- Team Setting Analytics Job (Recovery)
        OR JobId = '8753395b-8cc0-43a2-848f-61de02630724'    -- Processes Analytics Job
        OR JobId = '950deab4-5123-46a4-abd9-e3304baacc5a'    -- Test Point Sync Analytics Job (Recovery)
        OR JobId = '9609bcd9-9f5b-40ac-82d4-c475ec9a0984'    -- Test Runs Sync Analytics Job
        OR JobId = '99091932-e1d0-473f-ab8d-2a71f60caf3e'    -- Test Runs Sync Analytics Job (Recovery)
        OR JobId = 'afd82317-8d48-42fa-a3bb-00dd3e22035a'    -- Collection Analytics Job (Recovery)
        OR JobId = 'b2e1603d-43be-4bf4-a75b-ad13c6b9fc24'    -- Test Point Sync Analytics Job
        OR JobId = 'b388f317-1ac6-426f-a40c-3a930d1a9c0b'    -- Work Item Link Types Analytics Job
        OR JobId = 'b524c814-1093-4c40-a6dc-51f6397a4a15'    -- Test Results Sync Analytics Job (Recovery)
        OR JobId = 'b92e39dd-2a02-4044-b017-226e33c44187'    -- Analytics Maintain Staging Schedules Job
        OR JobId = 'bfa21cf5-5865-4c89-9d29-99fcbdfc4a5c'    -- Work Item Links Analytics Job (Recovery)
        OR JobId = 'c4b5bc26-c37e-4387-9f30-17725b43fffa'    -- Processes Analytics Job (Recovery)
        OR JobId = 'd2d0e457-9013-4843-b582-9d3f8b2073e0'    -- Test Configuration Sync Analytics Job (Recovery)
        OR JobId = 'd7ed949f-392c-4328-812c-06571c64dad0'    -- Test Case Reference Sync Analytics Job (Recovery)
        OR JobId = 'dd42395a-5b0c-468a-9ef6-5374377d3652'    -- Test Results Sync Analytics Job
        OR JobId = 'dd9ac434-092c-451c-b5cc-640d97cc2176'    -- Work Item Revisions Analytics Job (Recovery)
        OR JobId = 'e1b1570c-9be5-4279-afbf-2a1c36d939bf'    -- Work Item Links Analytics Job
        OR JobId = 'e3d798dd-55d3-44ab-8e91-9f8b5d2a514d'    -- Test Point History Sync Analytics Job (Recovery)
        OR JobId = 'e7574d45-89e1-4088-955a-e536def61567'    -- Test Suite Sync Analytics Job (Recovery)
        OR JobId = 'e7ce94e0-6069-4424-b501-5630431b247c'    -- WorkItem Area Analytics Job (Recovery)
        OR JobId = 'fcb7d04d-5f9f-4a37-971d-723580ff67d6'    -- WorkItem Iteration Analytics Job (Recovery)
        OR JobId = 'fd61e994-6916-463f-a9ce-4b217ed3dc95'    -- WorkItem Area Analytics Job
        OR JobId = 'fe3bf789-1b7d-4504-bed7-35775590bfe7'    -- Test Point History Sync Analytics Job
        OR JobId = '468B2974-4836-4F90-83E9-CF2D7432A8A7'    -- Test Plan Analytics Job
        OR JobId = 'E17BC5FF-3413-4598-823D-C4B85A1F53AF'    -- Test Plan Analytics Job (Recovery)
        OR JobId = '5ce180ee-3c58-4d12-80e6-ceccf7b09e7d'    -- TestResults analytics job tcm
        OR JobId = 'f4a76397-8993-4b1e-963a-d5dfb4541c7f'    -- TestResults analytics job tcm (Recovery)
        OR JobId = 'f17c101c-df6a-488e-9b75-258e315015f8'    -- TestRun Analytics job tcm
        OR JobId = '093ab808-1776-4e50-9ad5-8d4b82cc27d8'    -- TestRun Analytics job tcm (Recovery)
        OR JobId = '950e11ca-62a1-424f-9810-b253c24cf406'    -- Test Case Reference Analytics Job tcm
        OR JobId = '5b7a9c5f-c7d0-4aee-90d2-2fa63deaa90d'    -- Test Case Reference Analytics Job tcm (Recovery)
        OR JobId = '86B94D0B-BFD0-44DC-877B-BF9FC550C4B3'    -- Task Plan Analytics Job 
        OR JobId = '147E566D-9776-41A1-ADE6-99D9421D1221'    -- Task Plan Analytics Job (Recovery)
        OR JobId = '9F5D4356-C28C-4746-BA9F-8AEFFAD5CCC4'    -- Task Timeline Record Analytics Job
        OR JobId = 'FB818B11-CA5E-4B81-A8F0-F2682B3980A3'    -- Task Timeline Record Analytics Job (Recovery)
        OR JobId = 'A72F8A0A-2B38-42B8-B796-F8F0BED3E99F'    -- Task Definition Reference Analytics Job
        OR JobId = 'E71655FA-32E7-4AC7-BEC1-7B5004953A60'    -- Task Definition Reference Analytics Job (Recovery)
        OR JobId = 'BBDAF35E-FFDE-405C-931E-20F8B5602AEC'    -- Build Analytics job
        OR JobId = '3CD11578-47BD-4856-AA90-8DB3790B2BC4'    -- Build Analytics job (Recovery)
        OR JobId = '2fccba60-22db-45ad-8334-db1761191400'    -- Analytics DB Maintenance Job
        OR JobId = '315c619a-c4f5-4721-a850-4e86f98588f5'    -- Analytics Project Permissions Job
        OR JobId = '5549dec4-722d-488e-bd9f-6622fe281507'    -- Analytics Deleted Table Cleanup Job
        OR JobId = '63b34e3d-dd96-42b1-a262-8c2a6e3f127d'    -- Analytics Transform Job
        OR JobId = '78e8059e-c958-4dd7-a2e3-25260c700996'    -- Analytics Data Quality Job
        OR JobId = '924cf5fc-ddc7-4ec0-b283-13aa1e4a4996'    -- Analytics Data Quality Cleanup Job
        OR JobId = '9b61a767-f78e-4106-8886-45c9f560ec3f'    -- Analytics Stream Cleanup Job
        OR JobId = 'a060529e-b328-410c-bbb4-058421b5a0b4'    -- Analytics Time Zone Update Job
        OR JobId = 'd2f10407-d805-4c58-9539-29f51e201f13'    -- Analytics Calendar Update Job
    )
ORDER BY StartTime DESC