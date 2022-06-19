
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

SELECT  *  FROM PortfolioDatabase.dbo.Nashville

--Standardize Date format

SELECT SaleDate FROM PortfolioDatabase.dbo.Nashville;

ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD SalesDateStandardized date;

UPDATE PortfolioDatabase.dbo.Nashville 
SET SalesDateStandardized = CONVERT(Date,Saledate);

SELECT SalesDateStandardized 
FROM PortfolioDatabase.dbo.Nashville;


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address

SELECT PropertyAddress 
FROM PortfolioDatabase.dbo.Nashville
WHERE PropertyAddress IS NULL;


SELECT  *  
FROM PortfolioDatabase.dbo.Nashville
ORDER BY ParcelID;

--The data has same parcelIDs with different UniqueIds therefore, The propertyAddress will be the same for same parcelID and we will populate that address
--into the row where propertyaddress is null.

SELECT   a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioDatabase.dbo.Nashville a 
INNER JOIN PortfolioDatabase.dbo.Nashville b  --SELF JOIN
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress=IsNULL(a.PropertyAddress,b.PropertyAddress)FROM PortfolioDatabase.dbo.Nashville a 
INNER JOIN PortfolioDatabase.dbo.Nashville b  --SELF JOIN
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking Propertyaddress & Owneraddress in Address,City,State coloumns

SELECT  PropertyAddress
FROM PortfolioDatabase.dbo.Nashville

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortfolioDatabase.dbo.Nashville


ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD PropertyAddressSplit nvarchar(255);
UPDATE PortfolioDatabase.dbo.Nashville 
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );




ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD PropertyCitySplit nvarchar(255);
UPDATE PortfolioDatabase.dbo.Nashville 
SET PropertyCitySplit = SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1,LEN(PropertyAddress));


--Splitting OwnerAdress by Parsename

Select Parsename(Replace(OwnerAddress,',','.'),1)  AS STATE
FROM PortfolioDatabase.dbo.Nashville

Select  Parsename(Replace(OwnerAddress,',','.'),2)  AS CITY
FROM PortfolioDatabase.dbo.Nashville

Select Parsename(Replace(OwnerAddress,',','.'),3)  ADDRESS
FROM PortfolioDatabase.dbo.Nashville



ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD OwnerStateSplit nvarchar(255);
UPDATE PortfolioDatabase.dbo.Nashville 
SET OwnerStateSplit =Parsename(Replace(OwnerAddress,',','.'),1) ;


ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD OwnerCitySplit nvarchar(255);
UPDATE PortfolioDatabase.dbo.Nashville 
SET OwnerCitySplit =Parsename(Replace(OwnerAddress,',','.'),2) ;



ALTER TABLE PortfolioDatabase.dbo.Nashville
ADD OwnerAddressSplit nvarchar(255);
UPDATE PortfolioDatabase.dbo.Nashville 
SET OwnerAddressSplit =Parsename(Replace(OwnerAddress,',','.'),3) ;


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

--Converting Y into Yes and N in to No in SoldAsVacant coloumn 

UPDATE PortfolioDatabase.dbo.Nashville 
SET SoldAsVacant=CASE 
WHEN SoldAsVacant= 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
Else SoldAsVacant
END
FROM PortfolioDatabase.dbo.Nashville

--checking if the update statement executed sucessfully
SELECT Distinct(SoldAsVacant)
FROM PortfolioDatabase.dbo.Nashville


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates



SELECT *,
ROW_NUMBER() OVER(
                   PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,OwnerName ORDER BY [UniqueID ]) r_NO
				   
				   
				   FROM PortfolioDatabase.dbo.Nashville;



WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
                   PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,OwnerName ORDER BY [UniqueID ]) r_NO
				   
				   
				   FROM PortfolioDatabase.dbo.Nashville

)
DELETE 
From RowNumCTE
Where r_NO > 1




------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--Droping coloums we dont need 

ALTER TABLE PortfolioDatabase.dbo.Nashville

DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
				
