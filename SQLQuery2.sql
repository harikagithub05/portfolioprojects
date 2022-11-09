--cleaning data in SQL queries

select*
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------

--Standardize Date Format

select saledateconverted, convert(date, saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set saledate = convert(date, saledate)

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = convert (date, saledate)

-----------------------------------------------------------------------

--populate property address data

select*
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 Where a.PropertyAddress is null


 update a
 set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
 from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 Where a.PropertyAddress is null

 -------------------------------------------------------------------------

 --breaking out address into individual columns (Address, city, state)

 select PropertyAddress
 from PortfolioProject.dbo.NashvilleHousing
 --where propertyaddress is null
 --order by parcelID

 select 
 SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as address,
 SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, len(PropertyAddress)) as address

 from PortfolioProject.dbo.NashvilleHousing


 alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)


alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, len(PropertyAddress))


select*
from PortfolioProject.dbo.NashvilleHousing





select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(replace(owneraddress, ',', '.'), 3)
,PARSENAME(replace(owneraddress, ',', '.'), 2)
,PARSENAME(replace(owneraddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing




alter table NashvilleHousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(owneraddress, ',', '.'), 3)


alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(owneraddress, ',', '.'), 2)


alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(replace(owneraddress, ',', '.'), 1)


select*
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------

--change Y and N to yes and no in "sold as vacant" field


select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' then 'NO' 
	   ELSE SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' then 'NO' 
	   ELSE SoldAsVacant
	   end

---------------------------------------------------------------------------


--remove duplicates

with rownumCTE as(
select*,
    row_number() over(
	partition by parcelID,
                  propertyaddress,
				  saleprice,
				  saledate,
				  legalreference
				  order by
				  uniqueID
				  ) ROW_NUM
 
from portfolioproject.dbo.NashvilleHousing
--order by ParcelID
)
select*
from rownumCTE
WHERE row_num > 1
order by PropertyAddress


-------------------------------------------------------------------------------

--delete unused columns



select*
from PortfolioProject.dbo.NashvilleHousing

alter table portfolioproject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolioproject.dbo.NashvilleHousing
drop column saledate