/*

Project: Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate
From PortfolioProject.dbo.NashvilleHousing 
-- The result shows not only the date but time eg. 2016-02-10 00:00:00:00

-- Query below helps to remove the time portion from the date & Update the table in the database.

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing 

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

--- ALTERNATIVELY - Query below help alter & update table by adding a new column for the converted sales date

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Date (where it is null)

Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null
Order by ParcelID


-- Populating It (using self join .... i.e. joining the same table with itself)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City)

Select PropertyAddress
From PortfolioProject..NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City -- LEN(PropertyAddress)) as City (Removes the ',' at the end of the city name)
From PortfolioProject..NashvilleHousing 


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject..NashvilleHousing 


--ALTERNATIVE WAY

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerAddress, --PARSENAME is used to separate a column with period '.' delimitor. Hence the REPLACE function was used to replace the comma ', with a period '.' in the owner address' 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerCity, -- The numbers 1,2,3 in the PARSENAME query  represents each each of the sections of the text separated with a delimiter
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerState -- The arrangement of the numbers is backwards (i.e. 3,2,1 because PARSENAME separates the text with delimiters backwards
From PortfolioProject..NashvilleHousing 


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject..NashvilleHousing 

----------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" column.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing 
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing 


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
 
----------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing 
--Order by ParcelID
)

--DELETE
Select *
From RowNumCTE
Where row_num > 1

-- The above query help to see the duplicate rows in a new column named as row_num with the values as 2.

-- To delete the duplicate rows, replace the the Select function with the delete function 

--NB (It is NOT recommended to remove duplicates from an original database, instead create a Temp table and manipulate the data from there.)
----------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--NB (It is NOT recommended to delete unused columns from an original database, instead create a Temp table and manipulate the data from there)
--(OR create a VIEW for visualization with the needed columns only.)
----------------------------------------------------------------------------------------------------------------------------------------



