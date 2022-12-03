param(

        [Parameter(Mandatory=$true)]
        [string] 
        $newStorageAccountName,

        [Parameter(Mandatory=$true)]
        [string] 
        $newStorageAccountContainerName

)

$myCredential = Get-AutomationPSCredential -Name 'automationCredential'
$userName = $myCredential.UserName
$securePassword = $myCredential.Password
$newStorageAccountAccessKey1 = $myCredential.GetNetworkCredential().Password

$Context = New-AzStorageContext -StorageAccountName $newStorageAccountName -StorageAccountKey $newStorageAccountAccessKey1
$sasVHDurl=$vhdURL+$sasToken

$Context = New-AzStorageContext -StorageAccountName $newStorageAccountName -StorageAccountKey $newStorageAccountKey

Remove-AzStorageContainer -Name $newStorageAccountContainerName -Context $Context -Force

echo "The container has been deleted"
