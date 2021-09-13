
--Cleaning Data in SQL Queries

select * 
from Portfolio_Project.dbo.Housing_Data


--Standardize Data Format
select SaleDateCon, CONVERT(Date,SaleDate)
from Portfolio_Project.dbo.Housing_Data

ALTER TABLE Housing_Data
Add SaleDateCon Date;

Update Housing_Data
SET SaleDateCon = CONVERT(Date,SaleDate)



--Populate the Property Address Data
--Join same columns on parcel id is equal in row and unique id is different/not equal then populate the address.Where is just to check null values. ISNULL is used to see of there is null in a put values of b in there.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress	) 
from Portfolio_Project.dbo.Housing_Data a
JOIN Portfolio_Project.dbo.Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
	Where a.PropertyAddress is NULL

--We Update Table where there is no null values. After that run above query which gives blank table as there is no null values in property address.
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.Housing_Data a
JOIN Portfolio_Project.dbo.Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
	Where a.PropertyAddress is NULL


--Split Property Address in Individual Columns (Address, City)
Select PropertyAddress
from Portfolio_Project.dbo.Housing_Data
--Where PropertyAddress is null
--order by ParcelID


--Substring extracts some characters from a string. SUBSTRING(string, start, length).Syntax
--CHARINDEX gives position to the string
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from Portfolio_Project.dbo.Housing_Data


--Adding the above split into the housing dataset. Alter the table and add address and city column and then add data to it with Update
ALTER TABLE Portfolio_Project.dbo.Housing_Data
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


--Just like address we do the same for City as well
ALTER TABLE Portfolio_Project.dbo.Housing_Data
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Project.dbo.Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


 
--Split Owner Address in Individual Columns (Address, City, state). We can do the same as above using substring but we will use parsename
 Select OwnerAddress
 From Portfolio_Project.dbo.Housing_Data

 Select 
 PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
 , PARSENAME(REPLACE(OwnerAddress, ',','.') , 2) 
  , PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
 From Portfolio_Project.dbo.Housing_Data

 --Owner address
 ALTER TABLE Portfolio_Project.dbo.Housing_Data
 Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.Housing_Data
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.') , 3) 


--owner City
ALTER TABLE Portfolio_Project.dbo.Housing_Data
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project.dbo.Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)


--Owner State
ALTER TABLE Portfolio_Project.dbo.Housing_Data
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project.dbo.Housing_Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


--Chnage Y and N as Yes and NO in SoldAsVacant. Change it by using case statement and then update the table with same info. 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_Project.dbo.Housing_Data
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.Housing_Data

Update Portfolio_Project.dbo.Housing_Data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Remove Duplicates

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

From Portfolio_Project.dbo.Housing_Data
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unsused Columns
Select * 
from Portfolio_Project.dbo.Housing_Data

ALTER TABLE Portfolio_Project.dbo.Housing_Data
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

