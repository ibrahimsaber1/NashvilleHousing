/*
cleaning Data With SQL
*/ 

--1-- lOOK AT THE DATA WE WILL WORK ON
SELECT *
FROM portofolioProject..NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------
--2-- STANDRAIZE DATA FORMAT

--SELECT SaleDate ,cast(saledate as date) as saledate
--FROM portofolioProject..NashvilleHousing

--update portofolioProject..NashvilleHousing
--SET SaleDate = convert(date, saledate)

alter table portofolioProject..NashvilleHousing
ADD SALEDATE2 DATE;

update portofolioProject..NashvilleHousing
SET SALEDATE2 = convert(date, saledate)

SELECT SALEDATE2, convert(date, saledate)
from portofolioProject..NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------
--3-- POUPOLATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
from portofolioProject..NashvilleHousing

SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress ,b.[UniqueID ],b.ParcelID ,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
FROM portofolioProject..NashvilleHousing A
JOIN portofolioProject..NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
FROM portofolioProject..NashvilleHousing A
JOIN portofolioProject..NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
	 WHERE A.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------
--4-- BREDAKING PROPERTY ADDRESS INTO INDIVEDUAL COLUMNS (ADDRESS, CIIY, STATE)

SELECT PropertyAddress
from portofolioProject..NashvilleHousing
--WHERE PropertyAddress is null


SELECT 
    PropertyAddress,
   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))  AS City
FROM portofolioProject..NashvilleHousing

-- Add new columns to the table

alter table portofolioProject..NashvilleHousing
ADD propertyaddress2 NVARCHAR(300);

alter table portofolioProject..NashvilleHousing
ADD propertycity NVARCHAR(300);

-- Update the new columns with the split data
update portofolioProject..NashvilleHousing
SET propertyaddress2 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update portofolioProject..NashvilleHousing
SET propertycity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

-- Verify the updates

SELECT *
FROM portofolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------
--5-- BREDAKING OWNER ADDRESS INTO INDIVEDUAL COLUMNS (ADDRESS, CIIY, STATE)

SELECT OwnerAddress
from portofolioProject..NashvilleHousing

select
       PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as address
	   ,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as city
	   ,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as stste
from portofolioProject..NashvilleHousing

--- Add new columns for Address, City, and State to the table
ALTER TABLE portofolioProject..NashvilleHousing
ADD OwnerAddress2 NVARCHAR(300),
    OwnerCity NVARCHAR(300),
    OwnerState NVARCHAR(300);

-- Update the new columns with the split data
UPDATE portofolioProject..NashvilleHousing
SET 
    OwnerAddress2 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Verify the updates
SELECT OwnerAddress2, OwnerCity, OwnerState
FROM portofolioProject..NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------
--6-- CHANGE Y AND N  TO YES AND NO IN (SOLD AS VACANT)  FILED.
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portofolioProject..NashvilleHousing
GROUP BY SoldAsVacant

--CHANGE Y AND N  TO YES AND NO BY CAST STATMENT
SELECT 
    CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		WHEN SoldAsVacant = 'No' THEN 'NO'
		WHEN SoldAsVacant = 'Yes' THEN 'YES'
		ELSE SoldAsVacant
		END as SoldAsVacantupdate
FROM portofolioProject..NashvilleHousing
GROUP BY SoldAsVacant

--UPDATE THE CHANGE Y
update portofolioProject..NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		WHEN SoldAsVacant = 'No' THEN 'NO'
		WHEN SoldAsVacant = 'Yes' THEN 'YES'
		ELSE SoldAsVacant
		END

--CHECK THE CHANGE
select SoldAsVacant
from portofolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------
--7-- REMOVE Duplicate

-- Step 1: Create a Common Table Expression (CTE) with row numbers
WITH ROWNUMCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) AS ROW_NUM
    FROM portofolioProject..NashvilleHousing
)
SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM > 1
-- Step 2: Delete duplicate rows using the CTE
WITH ROWNUMCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) AS ROW_NUM
    FROM portofolioProject..NashvilleHousing
)
DELETE FROM ROWNUMCTE
WHERE ROW_NUM > 1;

---------------------------------------------------------------------------------------------------------------------------
--8-- Delete Unused Column

ALTER TABLE portofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict


ALTER TABLE portofolioProject..NashvilleHousing
DROP COLUMN saledate

--check the rusalte 

select *
from portofolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------
--9-- CHANGE THE COLUME NAME


EXEC sp_rename '[portofolioProject].[dbo].[NashvilleHousing].SALEDATE2', 'SaleDate', 'COLUMN';
EXEC sp_rename '[portofolioProject].[dbo].[NashvilleHousing].PropertyAddress2', 'PropertyAddress', 'COLUMN';
EXEC sp_rename '[portofolioProject].[dbo].[NashvilleHousing].Propertycity', 'PropertyCity', 'COLUMN';

--check the final rusalte 

select *
from portofolioProject..NashvilleHo


----THE END.