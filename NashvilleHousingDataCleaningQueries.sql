Select SaleDate, Cast(SaleDate as Date)
From PortfolioProject..NashvilleHousing


--Storing SaleDate as Date (Converting its type from DateTime to Date) in SaleDateConverted

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing


--Populating Property Address Data (Wherever NULL)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual columns (Street, City, State etc.)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress NVarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity NVarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress));

Select PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing

--Splitting the Owner's Address

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing
Where OwnerAddress is not null

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress NVarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity NVarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState NVarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No in 'Sold as Vacant' Column

Select Distinct(SoldAsVacant)
From PortfolioProject..NashvilleHousing

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
				   End


--Removing Duplicates

With RowNumCTE As (
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueId
				 ) Row_num
From PortfolioProject..NashvilleHousing)
Delete
From RowNumCTE
Where Row_num > 1

--Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, SaleDate, PropertyAddress