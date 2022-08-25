# Resource groupe name (a new one will be created if it doesn't exist)
$myResourceGroupName = 'RG-Canada'
# IP name from ARM Template (to get the value of the ip adress once the vm is created.)
$IPName = 'Zscaler-NSS-MGMT-IP'
# Shell Script URL
$scripturl = 'https://raw.githubusercontent.com/willguibr/nss-azure-deploy/nss-%232-upgrade-to-2019-template/scripts/znssCustomScriptExtension-flag.sh'
# NssCertificate.zip URL
$Certurl = 'https://github.com/willguibr/nss-azure-deploy/raw/nss-%232-upgrade-to-2019-template/assets/NssCertificate.zip'
# getting Default Gateway From User
$smnet_dflt_gw  = Read-Host -Prompt 'Input your Default Gateway'


$RGexistOrNew = az group exists -n $myResourceGroupName
if ($RGexistOrNew -eq $false)
{
    # ResourceGroup doesn't exist
    # Create RG First
    Write-Output 'RG does not  exit createing one ....'
    az group create --location canadacentral --name $myResourceGroupName
    Write-Output 'RG Created, Deploying...'
    az deployment group create --resource-group RG-Canada --template-file ./azuredeploy.json

}
else
{
    # ResourceGroup exist
    Write-Output 'RG exist, Deploying...'
    az deployment group create --resource-group RG-Canada --template-file ./azuredeploy.json
}
Start-Sleep 60

# Copying Shell Script To Virtual Machine
& '.\scripts\Copy-ShellScript.ps1' $IPName $myResourceGroupName $scripturl $Certurl $smnet_dflt_gw $user $Password
