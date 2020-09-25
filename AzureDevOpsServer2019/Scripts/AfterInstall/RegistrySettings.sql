SELECT *
FROM dbo.tbl_RegistryItems
WHERE PartitionId = 1
AND ParentPath LIKE '#\Service\Analytics%'