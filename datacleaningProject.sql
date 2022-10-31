 ---------------------------------------------------------------------------------------------------

 --DATA CLEANING PROJECT

 SELECT * 
 FROM data_cleaning_project..sheet
----------------------------------------------------------------------------------------------------

-- STANDARDISE DATE FORMAT(DATETIME -> DATE)

SELECT SaleDate, CONVERT(DATE, SaleDate) 
 FROM data_cleaning_project..sheet


 ALTER TABLE sheet
 ADD SaleDateConverted DATE;

 UPDATE sheet
 SET SaleDateConverted = CONVERT(DATE, SaleDate)

----------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA WITH NULL PROPERTY ADDRESS

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress , b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM data_cleaning_project..sheet AS a
 JOIN data_cleaning_project..sheet AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM data_cleaning_project..sheet AS a
 JOIN data_cleaning_project..sheet AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


----------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIZUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT PropertyAddress 
FROM data_cleaning_project..sheet

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1)   
FROM data_cleaning_project..sheet


SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))
FROM data_cleaning_project..sheet


ALTER TABLE sheet
ADD PropertySplitAddress Nvarchar(255);

UPDATE sheet
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1)   
FROM data_cleaning_project..sheet


ALTER TABLE sheet
ADD PropertySplitCity Nvarchar(255);

UPDATE sheet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))
FROM data_cleaning_project..sheet

----------------------------------------------------------------------------------------------------

--BREAKING OUT OWNER ADDRESS USING PARSENAME

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM data_cleaning_project..sheet

ALTER TABLE sheet
ADD OwnerSplitAddress Nvarchar(255),
 OwnerSplitCity Nvarchar(255), 
 OwnerSplitState Nvarchar(255);

 UPDATE sheet
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
						FROM data_cleaning_project..sheet

UPDATE sheet
SET	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
						FROM data_cleaning_project..sheet

UPDATE sheet
SET	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
						FROM data_cleaning_project..sheet

----------------------------------------------------------------------------------------------------

--CHANGE Y/N TO YES/NO IN 'SoldAsVacant' COLUMN

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM data_cleaning_project..sheet
GROUP BY SoldAsVacant

SELECT SoldAsVacant, 
CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
END
FROM data_cleaning_project..sheet
GROUP BY SoldAsVacant

UPDATE sheet
SET SoldAsVacant = 
					CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
					END
					FROM data_cleaning_project..sheet


----------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES
WITH rowNum AS(

SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelId ORDER BY SaleDate ) AS a
FROM data_cleaning_project..sheet
)

SELECT * 
FROM rowNum
WHERE a = 2


----------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMN 

SELECT * 
FROM data_cleaning_project..sheet
ALTER TABLE sheet
DROP COLUMN PropertyAddress, SaleDate

----------------------------------------------------------------------------------------------------