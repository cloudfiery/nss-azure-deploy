$myResourceGroupName = 'tst'
$IPName = 'Zscaler-NSS-MGMT-IP'
$RGexistOrNew = az group exists -n $myResourceGroupName
if ($RGexistOrNew -eq $false)
{
    # ResourceGroup doesn't exist
    # Create RG First
    echo 'RG does not  exit createing one ....'
    az group create --location westus2 --name $myResourceGroupName
    echo 'RG Created, Deploying...'
    az deployment group create --resource-group tst --template-file .\azuredeploy.json

}
else
{
    # ResourceGroup exist
    echo 'RG exist, Deploying...'
    az deployment group create --resource-group tst --template-file .\azuredeploy.json
}

# Copying Shell Script To Virtual Machine
& '.\scripts\Copy-ShellScript.ps1' $IPName $myResourceGroupName
