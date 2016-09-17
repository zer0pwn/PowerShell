$Array = @()
$sh = New-Object -COM WScript.Shell #Start by creating a COM Shell object
$Shortcuts = Get-Childitem -Filter '*.lnk' -Recurse -Force #Get shortcuts recursively 
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
$Filtered = $Array | Where-Object {$_.GUID -ne $null} | Where-Object {$_.GUID -ne ''}
$Filtered = $Filtered | Where-Object {$_.FolderName -ne $null} | Where-Object {$_.FolderName -ne ''}
$Filtered | ForEach-Object {
   Try {
        if (test-path $_.BadPath) { 
            rename-item $_.BadPath $_.GoodPath
            attrib -H $_.GoodPath   
                if (test-path $_.GoodPath) {remove-item $_.FullName} #Test if goodpath exists and then remove shortcut
            }
        Write-Host -ForegroundColor Green ("Cleaned up hijacked shortcut " + $_.FullName)
        }
    Catch {
        Write-Host -ForegroundColor Red "There is no GUID/Shortcut matches found."
        }
    }
Get-Childitem -Filter "{*}" -Recurse -Force | Select-Object FullName > C:\orphanedGUIDs.txt 
$Array | Export-CSV C:\FullArrayDump.csv
$Filtered | Export-CSV C:\FilteredDump.csv