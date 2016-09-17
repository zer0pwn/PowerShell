
$path = 'C:\Documents and Settings\wfoster\Desktop\test\'
$include = '*.lnk'
$sh = New-Object -COM WScript.Shell 
$Shortcuts = Get-Childitem -path $path -Recurse -include $include 
$Shortcuts | ForEach-Object {
    
    $foldername = ((Split-Path -leaf $_.Name) -Split '\.')[0] 
    $parentpath = Split-Path $_.FullName  
    if ($sh.CreateShortcut($_.Fullname).Arguments -match 'explorer.+(?<badguid>{\S+})') { 
        $guid = $matches.badguid 
        $goodpath = join-path $parentpath $foldername 
    } 
    $badpath = join-path $parentpath $guid 
    if ($guid -match '{\S+}') { 
        if (test-path $badpath) { 
            rename-item $badpath $goodpath
            attrib -H $goodpath 
            if (test-path $goodpath) {remove-item $_.Fullname} #Test if goodpath exists and then remove shortcut
            }
        }
    }
    