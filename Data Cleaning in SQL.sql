--- Populate Property Address Date (BASED ON PARCELID)
SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL


SELECT a.ParcelID, a.propertyaddress, b.ParcelID, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE nashville_housing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


SELECT
	SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) -1) AS Address,
	SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) +1, LENGTH(propertyaddress)) AS City
FROM nashville_housing

ALTER TABLE nashville_housing   
ADD PropertySplitAddress varchar(255);
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) -1) 


ALTER TABLE nashville_housing
ADD PropertySplitCity varchar(255);
UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) +1, LENGTH(propertyaddress))


---Breaking out ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State) - OWNER ADDRESS
SELECT 
	SPLIT_PART(OwnerAddress, ',', 1),
	SPLIT_PART(OwnerAddress, ',', 2),
	SPLIT_PART(OwnerAddress, ',', 3)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSpliAddress varchar(255);
UPDATE nashville_housing
SET OwnerSpliAddress = SPLIT_PART(OwnerAddress, ',', 1)

ALTER TABLE nashville_housing
ADD OwnerSplitCity varchar(255);
UPDATE nashville_housing
SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2)

ALTER TABLE nashville_housing
ADD OwnerSplitState varchar(255);
UPDATE nashville_housing
SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3)

--- Change Y and N to Yes and No in "Sold As Vacant" column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant 
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


--- REMOVE DUPLICATES - PARTITION BY TO LOOK AT UNIQUE VALUES

---------- To see how many duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				ORDER BY 
					UniqueID
	) row_num
FROM nashville_housing
)
SELECT * 
From RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress

---------- To Delete Duplicates
DELETE FROM nashville_housing
WHERE UniqueID IN (
	SELECT UniqueID
	FROM (
	SELECT UniqueID,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				ORDER BY 
					UniqueID
	) row_num
	FROM nashville_housing) s
WHERE row_num > 1
	)
-- ORDER BY propertyaddress


--- DELETE UNUSED COLUMNS

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress,
DROP COLUMN saledate;

select * 
from nashville_housing

