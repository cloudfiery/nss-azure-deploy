param(
    [Parameter(Mandatory=$true)]
    [string]
    $IPName,
    [Parameter(Mandatory=$true)]
    [string]
    $RG
)
$User = "zsroot"
$Password = "zsroot"
$scripturl = 'https://raw.githubusercontent.com/willguibr/nss-azure-deploy/nss-%232-upgrade-to-2019-template/scripts/znssCustomScriptExtension.sh'
$Command = "fetch $scripturl"
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($User, $secpasswd)
$ComputerName = az network public-ip show -g $RG -n $IPName --query "ipAddress"
echo "Loggin to  : $ComputerName As : $User"
$SessionID = New-SSHSession -ComputerName $ComputerName.trim('"') -AcceptKey -Credential $Credentials
echo 'Copy Shell Script...'
$Query = (Invoke-SshCommand -SSHSession $SessionID  -Command $Command).Output
echo 'Script Copied'
echo 'Sitting  Environment Variables...'
$MY_IP = $ComputerName.trim('"')
$confirm = Read-Host -Prompt 'do you want to configure name servers ? [y]yes;[n]no; default [n]'
while ($confirm -ne 'y' -And $confirm -ne 'n' -And $confirm -ne '') {
    $confirm = Read-Host -Prompt 'Please enter a valid answer [y]yes;[n]no ;enter [n]'

}
if ( $confirm -eq 'y' )
{
    $NEW_NAME_SERVER_IP = Read-Host -Prompt '1st Name Server IP '
    $Command2 = 'sed -i -e '+"'2s/^/MY_IP=$MY_IP ; NEW_NAME_SERVER_IP=$NEW_NAME_SERVER_IP ; NEW_NAME_SERVER_IP2=$NEW_NAME_SERVER_IP2 /'"+' znssCustomScriptExtension.sh'
    $confirm2 = Read-Host -Prompt 'do you want to configure a 2nd name servers ? [y]yes;[n]no; default [n]'
    while ($confirm2 -ne 'y' -And $confirm2 -ne 'n' -And $confirm2 -ne '') {
        $confirm2 = Read-Host -Prompt 'Please enter a valid answer [y]yes;[n]no ;enter [n]'

    }
    if ($confirm2 -eq 'y')
    {
        $NEW_NAME_SERVER_IP2 = Read-Host -Prompt '2nd Name Server IP'
        $Command2 = 'sed -i -e '+"'2s/^/MY_IP=$MY_IP ; NEW_NAME_SERVER_IP=$NEW_NAME_SERVER_IP ; NEW_NAME_SERVER_IP2=$NEW_NAME_SERVER_IP2 /'"+' znssCustomScriptExtension.sh'
    }
}
else
{
    $Command2 = 'sed -i -e '+"'2s/^/MY_IP=$MY_IP /'"+' znssCustomScriptExtension.sh'
}
echo $Command2
$Query2 = (Invoke-SshCommand -SSHSession $SessionID  -Command $Command2).Output
echo $Query2
Remove-SSHSession -Name $SessionID | Out-Null

