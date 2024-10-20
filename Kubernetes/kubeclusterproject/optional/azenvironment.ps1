# Note : Following script will create a necessary virtual network and infrastructure

#dependancies
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Update-Module -Name Az


#variables
$subscriptionId = "b08d6f99-9bea-4c84-a6bc-3d3b2dfe1a7d" # Replace with your actual subscription ID
$resourceGroupName = "kubecluster" # Specify the name of your resource group
$location = "EastUS" # Specify the Azure region for the resource group
$vnetName = "vnet-kubecluster" # The name for your virtual network
$subnetName = "snet-kubecluster" # The name for your subnet
$subnetAddressPrefix = "192.168.56.0/24" # The IP address range for your subnet
$vnetAddressSpace = "192.168.0.0/16" # The address space for your virtual network
$nsgName = "nsg-kubecluster" # Name for the NSG
$publicIPName = "pip-kubemaster" #Name of Public IP

# Connect to Azure with device authentication
Connect-AzAccount -UseDeviceAuthentication

# Get the list of Azure subscriptions available to your account
Get-AzSubscription

# Set a specific Azure subscription as the active subscription

Set-AzContext -SubscriptionId $subscriptionId

# Get a list of all resource groups in the current subscription
Get-AzResourceGroup

# Create a new Azure Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

#------------------------- Create VNet and Subnet

# Create the Azure Virtual Network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix $vnetAddressSpace
Write-Host "Virtual Network '$vnetName' created."
# Add a subnet to the Virtual Network
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork
Write-Host "Subnet '$subnetName' added to Virtual Network '$vnetName'."



#----------------------------Create the Network Security Group (NSG)
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName
Write-Host "Network Security Group '$nsgName' created."

# Create security rules for HTTP, HTTPS, and SSH within the NSG
$rule1 = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 80 -NetworkSecurityGroup $nsg
$rule2 = New-AzNetworkSecurityRuleConfig -Name "AllowHTTPS" -Description "Allow HTTPS" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 443 -NetworkSecurityGroup $nsg
$rule3 = New-AzNetworkSecurityRuleConfig -Name "AllowSSH" -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 22 -NetworkSecurityGroup $nsg

# Add the rules to the NSG
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName
$nsg | Set-AzNetworkSecurityGroup
Write-Host "Security rules for HTTP, HTTPS, and SSH added to NSG '$nsgName'."

# Associate the NSG with the previously created subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName
$subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$subnetConfig.NetworkSecurityGroup = $nsg
$vnet | Set-AzVirtualNetwork
Write-Host "NSG '$nsgName' associated with subnet '$subnetName'."

# Create a new public IP
New-AzPublicIpAddress -Name $publicIPName -ResourceGroupName $resourceGroupName -Location $location -Sku Standard -AllocationMethod Static

#------------------ VM Creation---------------------#
