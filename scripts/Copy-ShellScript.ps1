param(
    [Parameter(Mandatory=$true)]
    [string]
    $IPName,
    [Parameter(Mandatory=$true)]
    [string]
    $RG,
    [Parameter(Mandatory=$true)]
    [string]
    $scripturl,
    [Parameter(Mandatory=$true)]
    [string]
    $Certurl,
    [Parameter(Mandatory=$true)]
    [string]
    $smnet_dflt_gw,
    [Parameter(Mandatory=$true)]
    [string]
    $user,
    [Parameter(Mandatory=$true)]
    [string]
    $pwd

)
$ComputerName = az network public-ip show -g $RG -n $IPName --query "ipAddress"
$secpasswd = ConvertTo-SecureString $pwd -AsPlainText -Force
Write-Output "Loggin to  : $ComputerName As : $user"
$npwd  = '"'+$pwd+'"'
echo y | C:\Users\octoadmin\Downloads\plink.exe   $user@$ComputerName -pw $pwd  "fetch $scripturl;fetch $Certurl"
echo y | C:\Users\octoadmin\Downloads\plink.exe  -ssh $user@$ComputerName -pw $pwd  -t "echo $npwd | sudo -S sh znssCustomScriptExtension-flag.sh -g $smnet_dflt_gw"
