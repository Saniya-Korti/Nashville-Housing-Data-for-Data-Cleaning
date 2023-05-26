SELECT * FROM THV

--Standardize date format

SELECT saledate, CONVERT(Date,SaleDate)
FROM THV

SELECT saledateconverted, CONVERT(Date,SaleDate)
FROM THV

ALTER TABLE THV
ADD saledateconverted DATE

UPDATE THV
SET saledateconverted = CONVERT(Date,SaleDate)

--Populate property address

SELECT *
FROM THV
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM THV a
JOIN THV b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From THV a
JOIN THV b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out address into individual columns

SELECT PropertyAddress
FROM THV

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM THV

ALTER TABLE THV
Add PropertySplitAddress Nvarchar(255);

Update THV
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE THV
Add PropertySplitCity Nvarchar(255);

Update THV
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT OwnerAddress 
FROM THV

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM THV

ALTER TABLE THV
Add Ownersplitaddress Nvarchar(255)

UPDATE THV
SET Ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE THV
Add Ownersplitcity Nvarchar(255)

UPDATE THV
SET Ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE THV
Add Ownersplitstate Nvarchar(255)

UPDATE THV
SET Ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field

SELECT DISTINCT(Soldasvacant),count(Soldasvacant)
FROM THV
GROUP BY Soldasvacant
ORDER BY 2

SELECT Soldasvacant
, CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
       WHEN Soldasvacant = 'N' THEN 'No'
	   ELSE Soldasvacant
	   END
FROM THV

UPDATE THV
SET Soldasvacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
       WHEN Soldasvacant = 'N' THEN 'No'
	   ELSE Soldasvacant
	   END

--Remove Duplicate

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) row_num
FROM THV
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete Unused columns

ALTER TABLE THV
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,Saledate

SELECT * FROM THV 
WHERE OwnerName is not null
ORDER BY UniqueID  

