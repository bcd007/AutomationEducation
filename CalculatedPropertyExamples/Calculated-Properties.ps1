# Calculated properties session
# 08/19/2021

# Command to get all Azure Licenses
Get-AzureADSubscribedSku

# Hmmm.. Let's pick just a few properties
Get-AzureADSubscribedSku | Select-Object -Property SkuPartNumber,CapabilityStatus,ConsumedUnits

# Not very interesting or helpful, let's take a look at what we have to play with
Get-AzureADSubscribedSku | get-member

Get-AzureADSubscribedSku | Select-Object -expand PrepaidUnits

Get-AzureADSubscribedSku | Select-Object -expand PrepaidUnits | Select-Object -Property Enabled

# No root property for licenses that have been purchased, but it's a sub-property of .PrepaidUnits called 'Enabled'.
# Let's make a property for that using Calculated Properties!

# Do we understand how to create a hashtable or what's a hashtable?

$environments = @{
    Prod = 'PServer01'
    QA   = 'QServer01'
    Dev  = 'DServer01'
}

$environments

$environments["Prod"]

# Create a hash table where we have a Name and Expression key, and the Value is what we want the Name and output of our calculated property to be:

@{Name="CanWeShutItDown?";Expression={$_.CanShutdown}}

# So put that Hashtable to use, and create a custom property in your output of whatever you need!

get-service | Select-Object -Property Name,Status,@{Name="CanWeShutItDown?";Expression={$_.CanShutdown}}

# -- OR --

Get-AzureADSubscribedSku | Select-Object -Property SkuPartNumber,CapabilityStatus,@{Name="PurchasedUnits";Expression={$_.PrepaidUnits.Enabled}},ConsumedUnits

# Man, it would be sooper nice to see Licenses available. That doesn't exist in the objecty properies.. so I make it exist!
# And lets pipe this to Format-table OR use Format-Table for the output to get our results in a table

Get-AzureADSubscribedSku | Select-Object -Property SkuPartNumber,CapabilityStatus,@{Name="PurchasedUnits";Expression={$_.PrepaidUnits.Enabled}},ConsumedUnits,@{Name="AvailableUnits";Expression={($_.PrepaidUnits.Enabled) - ($_.ConsumedUnits)}}
# Icky results... WHAT we want but not HOW we want it

Get-AzureADSubscribedSku | Select-Object -Property SkuPartNumber,CapabilityStatus,@{Name="PurchasedUnits";Expression={$_.PrepaidUnits.Enabled}},ConsumedUnits,@{Name="AvailableUnits";Expression={($_.PrepaidUnits.Enabled) - ($_.ConsumedUnits)}} | Format-Table -AutoSize

# orrrr

Get-AzureADSubscribedSku | Format-Table -AutoSize -Property SkuPartNumber,CapabilityStatus,@{Name="PurchasedUnits";Expression={$_.PrepaidUnits.Enabled}},ConsumedUnits,@{Name="AvailableUnits";Expression={($_.PrepaidUnits.Enabled) - ($_.ConsumedUnits)}}

# What about running another command to create a calculated property?  I make one!!
Get-AzureADUser -ObjectId someuser@.contoso.com | Select-Object -Property ObjectID,DisplayName,UserPrincipalName,@{Name="OwnedObjectId";Expression={((Get-AzureADUserCreatedObject -ObjectId $_.ObjectID).ObjectID) -join ";" }},@{Name="OwnedObjectDisplayname";Expression={((Get-AzureADUserCreatedObject -ObjectId $_.ObjectID).displayName) -join ";"}}

# Maybe UserX has created some AD stuff?
Get-AzureADUser -ObjectId somuser@contoso.com | Select-Object -Property ObjectID,DisplayName,UserPrincipalName,@{Name="OwnedObjectId";Expression={((Get-AzureADUserCreatedObject -ObjectId $_.ObjectID).ObjectID) -join ";" }},@{Name="OwnedObjectDisplayname";Expression={((Get-AzureADUserCreatedObject -ObjectId $_.ObjectID).displayName) -join ";"}}


# For more fun and excitement!
get-help about_Calculated_Properties


# If Time Permits
# Get list of users with a specific license by SKUID and where they got the license from
Connect-MsolService

#All License SKUs for the first 100 users Get-MSOLUser returns
Get-MsolUser -MaxResults 100 -PipelineVariable user  | ForEach-Object{$user | Select-Object -expand Licenses | Select-Object -Property @{Name="UserDisplayName";Expression={$user.DisplayName}},@{Name="UserPrincipalName";Expression={$user.UserPrincipalName}},@{Name="LicenseSKU";Expression={$_.AccountSkuId}},@{Name="GrantingGroup";Expression={Get-MSOLGroup -ObjectId ($_.GroupsAssigningLicense.Guid) | Select-Object -expand DisplayName}}} | Format-Table -AutoSize

#Specific License SKU for the first 100 users Get-MSOLUser returns
Get-MsolUser -MaxResults 100 -PipelineVariable user | ForEach-Object{$user | Select-Object -expand Licenses | Where-Object{$_.AccountSkuId -like "*E3*"} | Select-Object -Property @{Name="UserDisplayName";Expression={$user.DisplayName}},@{Name="UserPrincipalName";Expression={$user.UserPrincipalName}},@{Name="LicenseSKU";Expression={$_.AccountSkuId}},@{Name="GrantingGroup";Expression={Get-MSOLGroup -ObjectId ($_.GroupsAssigningLicense.Guid) | Select-Object -expand DisplayName}}} | Format-Table -AutoSize
