-- Opening table to explore
SELECT *
FROM New_Project.Nashville2;
-- ORDER BY UniqueID

-- SaleDate is not in date datatype but in text
-- Updating SaleDate column so it has the correct format for converting it afterwards

SET SQL_SAFE_UPDATES = 0;

UPDATE Nashville2
set SaleDate=str_to_date(SaleDate, '%M %d, %Y');

-- Actually converting it to date datatype

ALTER TABLE nashville2
MODIFY SaleDate date;

-- Property address exploration
SELECT *
FROM New_Project.Nashville2
WHERE PropertyAddress IS null;

-- Filling those empty PropertyAddress cells
 
UPDATE Nashville2 t1,
	Nashville2 t2 
SET 
     t2.PropertyAddress = t1.PropertyAddress
WHERE
     t2.PropertyAddress IS NULL
         AND t2.ParcelID = t1.ParcelID
         AND t1.PropertyAddress is not null;
         
-- Breaking the Address into Individual columns using a substring and a Character index
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as Address
FROM New_Project.Nashville2;


-- Creating Property_split_address column and populating it with address alone

ALTER TABLE Nashville2
ADD Property_split_address
VARCHAR (255);

UPDATE Nashville2
SET Property_split_address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

-- Creating Property_split_city column and populating it with city

ALTER TABLE nashville2
ADD Property_split_city
VARCHAR (255);

UPDATE Nashville2
SET Property_split_city = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

-- Doing the same for OwnerAddress but with SUBSTRING_INDEX

SELECT
SUBSTRING_INDEX(OwnerAddress,',',1) AS Owner_split_street,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) AS Owner_split_city,
SUBSTRING_INDEX(OwnerAddress,',',-1) AS Owner_split_state
FROM New_Project.Nashville2;

-- Actually doing it, more efficient updating all the columns first and then all the updates

ALTER TABLE nashville2
ADD Owner_split_street
VARCHAR (255);

UPDATE Nashville2
SET Owner_split_street = SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE nashville2
ADD Owner_split_city
VARCHAR (255);

UPDATE Nashville2
SET Owner_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

ALTER TABLE nashville2
ADD Owner_split_state
VARCHAR (255);

UPDATE Nashville2
SET Owner_split_state = SUBSTRING_INDEX(OwnerAddress,',',-1);

-- Making the values of SoldasVacant uniform (Currently there are "YES", "Y", "NO", "N"
-- TEST

SELECT SoldasVacant,
	CASE 
		WHEN SoldasVacant = 'Y' THEN 'Yes'
		WHEN SoldasVacant = 'N' THEN 'No'
    ELSE SoldasVacant
    END
FROM New_Project.Nashville2;

-- Actual Update

UPDATE Nashville2
SET SoldasVacant = 	CASE 
		WHEN SoldasVacant = 'Y' THEN 'Yes'
		WHEN SoldasVacant = 'N' THEN 'No'
    ELSE SoldasVacant
    END;
-- Test to see if it worked correctly

SELECT DISTINCT(SoldasVacant)
FROM New_Project.Nashville2;

-- Remove Duplicates with CTE and ROW_NUMBER

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY UniqueID
                ) row_num2
                
FROM New_Project.Nashville2
)
SELECT *
FROM RowNumCTE
WHERE row_num2 > 1;

-- Looking for duplicates with a nested SELECT

SELECT * FROM 
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num4
FROM Nashville2
) nash_table
WHERE row_num4 > 1
ORDER BY UniqueID
;

-- Looking for duplicates with joins

SELECT *
FROM Nashville2 a
JOIN Nashville2 b 
WHERE a.UniqueID < b.UniqueID 
AND a.ParcelID = b.ParcelID
AND a.PropertyAddress = b.PropertyAddress
AND a.SalePrice = b.SalePrice
AND a.SaleDate = b.SaleDate
AND a.LegalReference = b.LegalReference
ORDER BY a.UniqueID;

-- Deleting duplicates

SET SQL_SAFE_UPDATES = 0; -- Safe Mode off


DELETE FROM Nashville2 WHERE UniqueID IN (
SELECT UniqueID FROM 
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num5
FROM Nashville2
) nashville_table
WHERE row_num5 > 1
ORDER BY UniqueID);

SET SQL_SAFE_UPDATES = 1;  -- Safe Mode on back again

-- Removing unused columns
ALTER TABLE New_Project.Nashville2
DROP COLUMN row_num,
DROP COLUMN cte_test2,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress