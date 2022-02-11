/*

Cleaning Data in SQL Queries

*/

select*
from NashvilleHousing

-- Standardize Date Format

select SaleDate, convert(Date, SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- The query above did not work to separtate the date and time. Using the ALTER TABLE query below garnered the result I was looking for.

alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted, convert(Date, SaleDate)
from NashvilleHousing

-- Populate Property Address Data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking Out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address

from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'), 3)
,parsename(replace(OwnerAddress, ',', '.'), 2)
,parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" Field.


select distinct(SoldAsVacant), Count(SoldASVacant)
from NashvilleHousing
Group By SoldAsVacant
Order By 2


select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			END
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			END


-- Remove Duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 Order By 
								UniqueID
								) row_num
from NashvilleHousing
--Order by ParcelID
)

delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
