/*
SQL Data Cleaning Project
*/

------------------------------------------------------------------------

--- Standarize Date Format

--- Add a new column to contain the new data
ALTER TABLE NashHousing 
ADD FormattedDate Date;

UPDATE NashHousing 
SET FormattedDate = Convert(Date,SaleDate);

SELECT FormattedDate
FROM NashHousing;

-- Remove the old column
ALTER TABLE NashHousing 
DROP COLUMN SaleDate;

-------------------------------------------------------------------------------------


--Populate property Addresse Data

--Doing a self join to Property Address Column to get rid of its null values 
SELECT n1.ParcelID, n1.PropertyAddress,n2.ParcelID, n2.PropertyAddress,ISNULL(n1.PropertyAddress,n2.PropertyAddress) AS newPropertyAddresse
FROM NashHousing n1
JOIN NashHousing n2
	ON n1.ParcelID= n2.ParcelID
	AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL

--- updating table
UPDATE n1
SET PropertyAddress= ISNULL(n1.PropertyAddress,n2.PropertyAddress)
FROM NashHousing n1
JOIN NashHousing n2
	ON n1.ParcelID= n2.ParcelID
	AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL

-- recheck the previous query there is now null values 

---------------------------------------------------------------------------

--- split the property addresse into (city,addresse) columns using SUBSTRING and CHARINDEX
SELECT PropertyAddress,
		SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS PropertySplittedAddress,
		SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyAddress)) AS PropertySplittedCity
FROM NashHousing

--- now updating the table with the new columns
--- Add a new column to have the new addresse
ALTER TABLE NashHousing
ADD PropertySplittedAddress varchar(225);

UPDATE NashHousing
SET PropertySplittedAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

-- Add a new column to have the new city
ALTER TABLE NashHousing
ADD PropertySplittedCity varchar(225);

UPDATE NashHousing
SET PropertySplittedCity = SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyAddress))
--- chech the result
SELECT PropertySplittedAddress , PropertySplittedCity
FROM NashHousing


------------------------------------------------------------------


--- Split the owner Addresse into (OwnerAddresse, OwnerCity, OwnerState) columnc Using PARSENAME function
SELECT OwnerAddress,
		PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),1) AS OwnerSplittedAddress,
		PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),2) AS OwnerSplittedCity,
		PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),3) AS OwnerSplittedState
FROM NashHousing

--- Updating the table with the new columns
ALTER TABLE NashHousing
ADD OwnerSplittedAddress varchar(225)

UPDATE NashHousing
SET OwnerSplittedAddress = PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),1)

ALTER TABLE NashHousing
ADD OwnerSplittedCity varchar(225)

UPDATE NashHousing
SET OwnerSplittedCity = PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),2)

ALTER TABLE NashHousing
ADD OwnerSplittedState VARCHAR(225)

UPDATE NashHousing
SET OwnerSplittedState= PARSENAME(REVERSE(REPLACE(OwnerAddress,',','.')),3)

--- recheck the results
SELECT OwnerSplittedAddress, OwnerSplittedCity, OwnerSplittedState
FROM NashHousing


--------------------------------------------------------------------------------


--- Update SoldAsVacant column to have just Yes or No Values
 
UPDATE NashHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant='Y' THEN 'Yes'
						WHEN SoldAsVacant='N' THEN 'No'
						ELSE SoldAsVacant
					END

--- check the result of the updated column
SELECT SoldAsVacant
FROM NashHousing
WHERE SoldAsVacant IN ('Y','N') ------- this will not give any result


---------------------------------------------------------------------


--- Remove Duplicate rows Using ROWNUMBER()

WITH CTEDuplicate AS(
SELECT *,ROW_NUMBER() OVER (PARTITION BY 
							ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
							ORDER BY ParcelID) AS row_num
FROM NashHousing
)
DELETE                           --- this will delete all duplicates 
FROM CTEDuplicate
WHERE row_num >1

--- to check they are removed replace the DELETE Comand with Select * , it might returns none!!


-----------------------------------------------------------------------------------------------


---- Removing unwanted columns
-- It is not prefered to remove columns from the Actual Dataset 
-- For Practise Purpose, we can just remove the the modified columns above and some othe using the following query.
ALTER TABLE NashHousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict


