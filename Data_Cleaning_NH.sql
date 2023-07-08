/*

--Data Cleaning in SQL: Nashville Housing Dataset

*/


SELECT *
FROM dbo.NashvilleHousing
GO

/*

Standadizing the Date Format

*/


SELECT SaleDate
FROM dbo.NashvilleHousing
GO

BEGIN TRAN

ALTER TABLE dbo.NashvilleHousing
ALTER COLUMN SaleDate Date Not Null

SELECT SaleDate
FROM dbo.NashvilleHousing

COMMIT TRAN
GO


/*

Populating the Property Address Column with Data

*/


SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT X.ParcelID, X.PropertyAddress, Y.ParcelID, Y.PropertyAddress, ISNULL(X.PropertyAddress, Y.PropertyAddress)
FROM dbo.NashvilleHousing AS X
JOIN dbo.NashvilleHousing AS Y
ON X.ParcelID = Y.ParcelID
AND X.[UniqueID ] <> Y.[UniqueID ]
WHERE X.PropertyAddress IS NULL


BEGIN TRAN

UPDATE X
SET PropertyAddress = ISNULL(X.PropertyAddress, Y.PropertyAddress)
FROM dbo.NashvilleHousing AS X
JOIN dbo.NashvilleHousing AS Y
ON X.ParcelID = Y.ParcelID
AND X.[UniqueID ] <> Y.[UniqueID ]
WHERE X.PropertyAddress IS NULL

COMMIT TRAN


/*

Splitting the Propoerty Address column into individual columns

*/

SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT CHARINDEX(',', PropertyAddress)
FROM dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
ADD Address NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE dbo.NashvilleHousing
ADD City NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))


EXEC SP_RENAME 'NashvilleHousing.Address', 'NewPropertyAddress'
EXEC SP_RENAME 'NashvilleHousing.City', 'NewPropertyCity'


SELECT *
FROM dbo.NashvilleHousing


/*

Splitting the Owner Address column into individual columns

*/


SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT
PARSENAME(OwnerAddress,1)
FROM dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
ADD NewOwnerAddress NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE dbo.NashvilleHousing
ADD NewOwnerCity NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE dbo.NashvilleHousing
ADD NewOwnerState NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM dbo.NashvilleHousing


/*

Changing 'Y' and 'N' from the 'Sold as Vacant' column to 'Yes' and 'No' respectively

*/


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM dbo.NashvilleHousing


BEGIN TRAN

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

COMMIT TRAN


/*

Removing Duplicates

*/

SELECT *
FROM dbo.NashvilleHousing

SELECT *,
		ROW_NUMBER() OVER 
						(
						 PARTITION BY ParcelID,
									  PropertyAddress,
					                  SalePrice,
					                  SaleDate,
					                  LegalReference
						 ORDER BY
									  UniqueID
						) AS Row_Num
FROM dbo.NashvilleHousing
ORDER BY ParcelID


WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER 
						(
						 PARTITION BY ParcelID,
									  PropertyAddress,
					                  SalePrice,
					                  SaleDate,
					                  LegalReference
						 ORDER BY
									  UniqueID
						) AS Row_Num
FROM dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1

--SELECT *
--FROM RowNumCTE
--WHERE Row_Num > 1


/*

Deleting Unnecessary Columns

*/


SELECT *
FROM dbo.NashvilleHousing


BEGIN TRAN

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

COMMIT TRAN

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM dbo.NashvilleHousing