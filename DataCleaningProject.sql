--Data Cleaning Project
-- Data set I will be using: Nashville Housing Data (2024)

select top 1000 *
from PortfolioProject..NashvilleCleaningData


--Updating the property address data

select PropertyAddress
from PortfolioProject..NashvilleCleaningData
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleCleaningData a
join PortfolioProject..NashvilleCleaningData b
	on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null 

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleCleaningData a
join PortfolioProject..NashvilleCleaningData b
	on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null

-- Breaking up the address into separate columns (Address, city, state)
	
select PropertyAddress
from PortfolioProject..NashvilleCleaningData
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress)) Address
from PortfolioProject..NashvilleCleaningData

ALTER TABLE NashvilleCleaningData
add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleCleaningData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) 


ALTER TABLE NashvilleCleaningData
add PropertySplitCity Nvarchar(255)

UPDATE NashvilleCleaningData
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress)) 


--Another way to break up the Address into separate columns


select OwnerAddress
from PortfolioProject..NashvilleCleaningData

select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) Street,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) City,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) State
from PortfolioProject..NashvilleCleaningData

ALTER TABLE NashvilleCleaningData
add OwnerSplitStreet Nvarchar(255)

ALTER TABLE NashvilleCleaningData
add OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleCleaningData
add OwnerSplitState Nvarchar(255)

UPDATE NashvilleCleaningData
set OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) 

UPDATE NashvilleCleaningData
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) 

UPDATE NashvilleCleaningData
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) 

-- Change 0 and 1 to Yes and No in 'Sold as Vacant' column

select distinct(SoldAsVacant), count(Soldasvacant)
from NashvilleCleaningData
group by SoldAsVacant

ALTER TABLE NashvilleCleaningData ALTER COLUMN SoldAsVacant VARCHAR(20) NOT NULL;


select SoldAsVacant
,
Case when SoldAsVacant = '0' then 'No'
	 when SoldAsVacant = '1' then 'Yes'
	 else cast(SoldAsVacant as varchar(10))
	 end
from PortfolioProject..NashvilleCleaningData


UPDATE NashvilleCleaningData
set SoldAsVacant = 
Case when SoldAsVacant = '0' then 'No'
	 when SoldAsVacant = '1' then 'Yes'
	 else cast(SoldAsVacant as varchar(10))
	 end

-- Removing Duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over (partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by ParcelID
				 ) row_num
from PortfolioProject..NashvilleCleaningData
)
delete
from RowNumCTE
where row_num > 1


-- Deleting unused columns

select top 1000 *
from PortfolioProject..NashvilleCleaningData

alter table PortfolioProject..NashvilleCleaningData
drop column OwnerAddress, PropertyAddress, TaxDistrict