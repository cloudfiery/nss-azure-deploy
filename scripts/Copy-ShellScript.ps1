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
    $smnet_dflt_gw

)
#ssh Parameters
$User = "zsroot"
$Password = "zsroot"
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($User, $secpasswd)
$ComputerName = az network public-ip show -g $RG -n $IPName --query "ipAddress"
#$ComputerName = "20.116.57.141"

#copoy command
$copycommand = "fetch $scripturl;fetch $Certurl"

#copy script and certificate
echo "Loggin to  : $ComputerName As : $User"
$SessionID = New-SSHSession -ComputerName $ComputerName.trim('"') -AcceptKey -Credential $Credentials
echo 'Copying Shell Script and NSS Certificate ...'
$Query = $(Invoke-SshCommand -SSHSession $SessionID  -Command $copycommand).Output
echo 'Script and Certificate Copied, Executing Script'

#Execute Script 
$ExShellScript = "sh znssCustomScriptExtension-flag.sh -g $smnet_dflt_gw"
echo $ExShellScript
$Query2 = $(Invoke-SshCommand -SSHSession $SessionID  -Command $ExShellScript).Output
$Query2 = $Query2.split("`n")
echo $Query2
Remove-SSHSession -Name $SessionID | Out-Null
