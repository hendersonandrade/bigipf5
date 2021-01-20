$Cred = Get-Credential

$F5VS = Invoke-RestMethod -Uri 'https://BigIPURL/mgmt/tm/ltm/virtual?ver=13.0.0' -Credential $Cred
$F5Pool = Invoke-RestMethod -Uri 'https://BigIPURL/mgmt/tm/ltm/pool?ver=13.0.0' -Credential $Cred


$F5VS.items[1].pool

$Result = @()

foreach ($VIP in $F5VS.items) {
    $HashTable = @{
        VIPName        = $VIP.name;
        VIPPool        = $VIP.pool;
        VIPDescription = $VIP.description;
        VIPAddress     = $VIP.destination
    }

    $pool = ($VIP.pool -split '/')[-1]
    
    if ($VIP.pool) {
        $F5Nodes = Invoke-RestMethod -Uri "https://BigIPURL/mgmt/tm/ltm/pool/~Common~$pool/members?ver=13.0.0" -Credential $cred
        $HashTable.Add('Members', [System.Collections.ArrayList]@())
        $F5Nodes.items.name | foreach-object {$HashTable.Members.Add($_) | Out-Null}
    }
    $PSObjectTable = New-Object PSObject -property $HashTable
    $Result += $PSObjectTable
}

$Result[1]
$Result | select-object VIPName, VIPPool, VIPDescription, VIPAddress, @{Name = "Members"; Expression = {$_.Members}} | export-csv c:\temp\F5Mapping.csv -notypeinformation
$Result[1] | select-object VIPName, VIPPool, VIPDescription, VIPAddress,  Members | export-csv c:\temp\sample.csv -notypeinformation

$MembersList = Get-Content C:\temp\MembersList.txt

foreach ($pool in $MemberList) {
    $F5Nodes = Invoke-RestMethod -Uri $pool -Credential $cred
    $F5Nodes.items.name  
}
