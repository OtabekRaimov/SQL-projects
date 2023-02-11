/*

 Data cleaning in SQL

*/

-------------------------------------------------------------------------------------------------------------------------------------------

-- Let's take a look at our data

SELECT * FROM Projects.dbo.NashvilleHousing
ORDER BY [UniqueID ]

-- Standartize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate) FROM Projects.dbo.NashvilleHousing

ALTER TABLE Projects.dbo.NashvilleHousing
ADD SaleDateConverted DATE

UPDATE Projects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------

-- Populate proper address data 

SELECT A.ParcelID
	  ,A.PropertyAddress
	  ,B.ParcelID
	  ,B.PropertyAddress
	  ,ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Projects.dbo.NashvilleHousing A
JOIN Projects.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Projects.dbo.NashvilleHousing A
JOIN Projects.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)),
PropertyAddress 
FROM Projects.dbo.NashvilleHousing

ALTER TABLE Projects.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Projects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Projects.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Projects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Projects.dbo.NashvilleHousing

ALTER TABLE Projects.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Projects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Projects.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Projects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Projects.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Projects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant)
	   ,COUNT(SoldAsVacant) 
FROM Projects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant END
FROM Projects.dbo.NashvilleHousing

UPDATE Projects.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant END

-------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


;WITH DUPLICATE_CTE AS (
SELECT *
	,ROW_NUMBER() OVER (PARTITiON BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS Row_num
FROM Projects.dbo.NashvilleHousing
)
SELECT * FROM DUPLICATE_CTE
WHERE Row_num > 1



;WITH DUPLICATE_CTE AS (
SELECT *
	,ROW_NUMBER() OVER (PARTITiON BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS Row_num
FROM Projects.dbo.NashvilleHousing
)
DELETE FROM DUPLICATE_CTE
WHERE Row_num > 1

-------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting unusuad columns

ALTER TABLE Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict 

ALTER TABLE Projects.dbo.NashvilleHousing
DROP COLUMN SaleDate

-------------------------------------------------------------------------------------------------------------------------------------------

-- Final version of the dataset

SELECT * FROM Projects.dbo.NashvilleHousing
ORDER BY [UniqueID ]