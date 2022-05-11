[CmdletBinding()] 
Param (
    [Parameter(Mandatory = $True)] [string[]] $path,
    [Parameter(Mandatory = $False)] [string[]] $only,
    [Parameter(Mandatory = $False)] [string[]] $exclude,
    [Parameter(Mandatory = $False)] [string[]] $excludepath
)

. .\"utils.ps1"

$folder = Get-Item $path
#Write-Host "[+] Actual Folder: " $folder
#Write-Host "[+] Only: " $only
#Write-Host "[+] Exclude: " $exclude
#Write-Host "[+] Exclude Path: " $excludepath

$is_set_only = $PSBoundParameters.ContainsKey('only')
$is_set_exclude = $PSBoundParameters.ContainsKey('exclude')
$is_set_excludepath = $PSBoundParameters.ContainsKey('excludepath')

# Remove files defined on excludepath param
function filter_excludepath( [System.Collections.ArrayList]$files ) {

    foreach($file in $files.Where( { $_.FullName -in $excludepath } ) ) {
        $files.Remove($file)
    }

    return $files
}

# Remove files with extension not defined on only param
function filter_only( [System.Collections.ArrayList]$files ) {

    foreach($file in $files.Where({ !($_.Extension -in $only) })) {
        $files.Remove($file)
    }

    return $files

}

# Remove files with extension defined on exclude param
function filter_exclude( [System.Collections.ArrayList]$files ) {

    foreach($file in $files.Where({ !($_.Extension -in $exclude) })) {
        $files.Remove($file)
    }

    return $files

}

[System.Collections.ArrayList]$files = Get-ChildItem $folder -Recurse -File

# No tiene sentido usar el only junto con el exclude
if ( $is_set_only -and $is_set_exclude ) {
    Write-Host "[+] Parameters only and exclude cannot be used together"
    exit
}

if ( $is_set_excludepath ) { $files = filter_excludepath($files) }

if ( $is_set_only ) { $files = filter_only($files) }

if ( $is_set_exclude ) { $files = filter_exclude($files) }

#Write-Host "`n`r[+] Filtered Files: "
#foreach ($file in $files) { $file.FullName }

# [+] Determine encoding
foreach( $file in $files ) {

    #Write-Host "[+] Checking " $file.FullName

    # Get File Byte Array
    [Byte[]]$bytes = Get-Content -Encoding Byte $file.Fullname

    # Byte Array 2 Hex Array
    $hex_array = ($bytes|ForEach-Object ToString X2)
    $hex_array_size = $hex_array.Count

    if ( $hex_array_size -eq 0) {
        Write-Host "`t" $file.Fullname "cannot be parsed because it is empty." -ForegroundColor Green
    } else {
        
        $msg = $null
        $faulty_bytes = 0

        # Check encoding type
        if ( Get-file-looks-utf8-with-BOM($file) ) {

            $file_encoding = [Text.Encoding]::GetEncoding(65001).EncodingName + " with BOM"

        } elseif ( IsUtf8 -hex_array_size $hex_array_size -hex_array $hex_array -msg ([ref]$msg) -faulty_bytes ([ref]$faulty_bytes) ) {

            #Write-Host "`tMessage: " $msg
            #Write-Host "`tFaulty Bytes: " $faulty_bytes
            
            $file_encoding = [Text.Encoding]::GetEncoding(65001).EncodingName + " without BOM"

        } else {
            $file_encoding = [Text.Encoding]::GetEncoding(20127).EncodingName + " (or unknown encoding)"
        }

        Write-Host "`t" $file.Fullname " ==> " $file_encoding -ForegroundColor Green
    }

}

# .\check_utf8.ps1 -path .\wachin\ -only .txt -excludepath H:\Powershell\wachin\untitled1.txt, H:\Powershell\wachin\hack.hhh