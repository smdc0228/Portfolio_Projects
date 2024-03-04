SELECT * 
FROM [Portfolio Project].[dbo].[NashvilleHousingData]

-- Cleaning data in SQL queries
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Portfolio Project].[dbo].[NashvilleHousingData]

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted DATE; 

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

--  Populate property address data 
SELECT *
FROM 
-- WHERE PropertyAddress is null
ORDER BY ParcelID

-- Populate a value to PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM [Portfolio Project].dbo.NashvilleHousingData a
JOIN [Portfolio Project].dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Update the value we got 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM [Portfolio Project].dbo.NashvilleHousingData a
JOIN [Portfolio Project].dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out the address into individual columns (address, city, state)
SELECT PropertyAddress
FROM [Portfolio Project].[dbo].[NashvilleHousingData]
-- WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].[dbo].[NashvilleHousingData]


-- Create 2 columns and add the values
ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousingData]
ADD PropertySplitAddress NVARCHAR (255); 

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousingData]
ADD PropertySplitCity NVARCHAR (255); 

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- View the results
SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousingData

-- Owner Address
SELECT OwnerAddress 
FROM [Portfolio Project].dbo.NashvilleHousingData


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3) AS OwnerAddressUpdated
, PARSENAME (REPLACE(OwnerAddress, ',', '.') , 2) AS OwnerAddressCity
, PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1) AS OwnerAddressState
FROM [Portfolio Project].dbo.NashvilleHousingData

-- Add the columns 
ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousingData]
ADD OwnerAddressUpdated NVARCHAR (255); 

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET OwnerAddressUpdated = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3) 

ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousingData]
ADD OwnerAddressCity NVARCHAR (255); 

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET OwnerAddressCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 2) 

ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousingData]
ADD OwnerAddressState NVARCHAR (255); 

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET OwnerAddressState = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1) 

-- View the results
SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousingData

-- Change Y and N to Yes and No in "Sold as Vacant"
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].[dbo].[NashvilleHousingData]
GROUP BY SoldAsVacant
ORDER BY 2

--Start changing it
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END
FROM [Portfolio Project].[dbo].[NashvilleHousingData]

UPDATE [Portfolio Project].[dbo].[NashvilleHousingData]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END


-- Remove duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,  
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID 
					) row_num

FROM [Portfolio Project].dbo.NashvilleHousingData)
--Deleting duplicates
--DELETE  
--FROM RowNumCTE
--WHERE row_num > 1
----ORDER BY PropertyAddress

-- Checking after deletion
SELECT *  
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete unused columns
SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousingData

-- Delete tables
ALTER TABLE [Portfolio Project].dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousingData
DROP COLUMN SaleDate