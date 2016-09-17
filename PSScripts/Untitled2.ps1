#William Foster with the help of Bob Daniel (The man, the myth, the legend.) 
$Array = @()
$sh = New-Object -COM WScript.Shell #Start by creating a COM Shell object
$Shortcuts = Get-Childitem '*.lnk' -Recurse #Get shortcuts recursively 
$Shortcuts | ForEach-Object {
    $guid = $null
    $foldername = ((Split-Path -leaf $_.Name) -Split '\.')[0] #Get Foldername
    $parentpath = Split-Path $_.FullName  #Get the parent path
    if ($sh.CreateShortcut($_.Fullname).Arguments -match 'explorer.+(?<badguid>{\S+})') {
            $guid = $matches.badguid #Regular expression to get GUID from shortcut arguments
            $badpath = join-path $parentpath $guid #Create bad path by joining shortcuts parentpath with the guid
            $goodpath = join-path $parentpath $foldername #Create goodpath by joining the good foldername with the shortcuts parent path
    }
    
    $row = New-Object System.Object # Create an object to append to the array
    $row | Add-Member -MemberType NoteProperty -Name "GUID" -Value "$guid"
    $row | Add-Member -MemberType NoteProperty -Name "FolderName" -Value "$foldername"
    $row | Add-Member -MemberType NoteProperty -Name "BadPath" -Value "$badpath"
    $row | Add-Member -MemberType NoteProperty -Name "GoodPath" -Value "$goodpath"
    $row | Add-Member -MemberType NoteProperty -Name "FullName" -Value $_.FullName
    $Array += $row

}
$Filtered = $Array | Where-object {$_.GUID -ne $null} | Where-Object {$_.GUID -ne ''}
#if (test-path $Filtered.BadPath) { 
#        rename-item $Filtered.BadPath $Filtered.GoodPath
#        attrib -H $Filtered.GoodPath
#        if (test-path $Filtered.GoodPath) {remove-item $Filtered.FullName} #Test if goodpath exists and then remove shortcut
#}