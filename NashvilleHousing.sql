/*
Data Cleaning
*/

SELECT * 
From PortfolioProjects.dbo.NashvilleHousing

/*
Standarize Date Format
*/

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjects.dbo.NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate);

/*
Populate Property Address Data
*/

SELECT * 
From PortfolioProjects.dbo.NashvilleHousing
-- WHERE PropertyAddress is null;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID];

/* 
Breakign out Address into Individual Columns (Address, City, State)
*/

SELECT PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProjects.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


SELECT * 
From PortfolioProjects.dbo.NashvilleHousing;



SELECT OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress,',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
From PortfolioProjects.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1);


/*
Change Y and N to Yes and No in "Sold ad Vacant" field
*/

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
order by 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProjects.dbo.NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProjects.dbo.NashvilleHousing;


/* Remove Duplicates */

WITH RowNumCTE AS 
	(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
		) row_num
	From PortfolioProjects.dbo.NashvilleHousing
	-- ORDER BY ParcelID;
	)
DELETE 
FROM RowNumCTE
WHERE row_num >1;
 -- ORDER BY PropertyAddress;

 
WITH RowNumCTE AS 
	(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
		) row_num
	From PortfolioProjects.dbo.NashvilleHousing
	-- ORDER BY ParcelID;
	)
SELECT * 
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress;


/*
Delete Unused Columns
*/

SELECT *
From PortfolioProjects.dbo.NashvilleHousing;

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;