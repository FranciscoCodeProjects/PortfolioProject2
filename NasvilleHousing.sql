--Cleaning Data in SQL Queries

Select*
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

-- Populate Property Address data where PropertyAddress is null, ParcellID is the same, so we input the correct PropertyAddress 

Select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
-- Through Substring


Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

-----------------------------------------------------------------------------------------------------------

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress))

Select*
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------
-- Through ParseName


Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
, PARSENAME(Replace(OwnerAddress, ',','.'), 2)
, PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

-----------------------------------------------------------------------------------------------------------

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

------------------------------------------------------------------------------------------------------------


Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

------------------------------------------------------------------------------------------------------------

Select*
from PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		end

-- To check if it worked

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


-- Remove Duplicates all data is the same expect from UniqueID

With RowNumCTE as(
Select*,
	ROW_NUMBER() over(
	Partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)

Delete
from RowNumCTE
where row_num > 1


-- Check to see if there is any duplicates left

With RowNumCTE as(
Select*,
	ROW_NUMBER() over(
	Partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)

Select*
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

Select*
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column TaxDistrict

-- Check if everything got deleted correctly

Select*
From PortfolioProject.dbo.NashvilleHousing