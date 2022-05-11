<#
    http://www.unicode.org/versions/Unicode7.0.0/UnicodeStandard-7.0.pdf (page 124, 3.9 "Unicode Encoding Forms", "UTF-8")

    https://sites.google.com/site/markusicu/unicode/utf-8-bytes

    Table 3-7. Well-Formed UTF-8 Byte Sequences
    -----------------------------------------------------------------------------
    |  Code Points        | First Byte | Second Byte | Third Byte | Fourth Byte |
    |  U+0000..U+007F     |     00..7F |             |            |             |
    |  U+0080..U+07FF     |     C2..DF |      80..BF |            |             |
    |  U+0800..U+0FFF     |         E0 |      A0..BF |     80..BF |             |
    |  U+1000..U+CFFF     |     E1..EC |      80..BF |     80..BF |             |
    |  U+D000..U+D7FF     |         ED |      80..9F |     80..BF |             |
    |  U+E000..U+FFFF     |     EE..EF |      80..BF |     80..BF |             |
    |  U+10000..U+3FFFF   |         F0 |      90..BF |     80..BF |      80..BF |
    |  U+40000..U+FFFFF   |     F1..F3 |      80..BF |     80..BF |      80..BF |
    |  U+100000..U+10FFFF |         F4 |      80..8F |     80..BF |      80..BF |
    -----------------------------------------------------------------------------
#>

Function IsUtf8 {

    [CmdletBinding()] 
    Param (
        [Parameter(Mandatory = $True)] [string[]]$hex_array,
        [Parameter(Mandatory = $False)] [int]$hex_array_size,
        [Parameter(Mandatory = $False)] [ref]$msg,
        [Parameter(Mandatory = $False)] [ref]$faulty_bytes
    )

    $i = 0

    $hex_array = ($hex_array|ForEach-Object {"0x$_"})

    while ($i -lt $hex_array_size)
    {

        if ($hex_array[$i] -le "0x7F") # 00..7F */
        {
            $i += 1
        }
        elseif ($hex_array[$i] -ge "0xC2" -and $hex_array[$i] -le "0xDF") # C2..DF 80..BF */
        {
            if ($i + 1 -lt $hex_array_size) # Expect a 2nd byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte between C2 and DF, expecting a 2nd byte between 80 and BF"
                    $faulty_bytes.value = 2
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte between C2 and DF, expecting a 2nd byte."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 2
        }
        elseif ($hex_array[$i] -eq "0xE0") # E0 A0..BF 80..BF */
        {
            if ($i + 2 -lt $hex_array_size) # Expect a 2nd and 3rd byte */
            {
                if ($hex_array[$i + 1] -lt "0xA0" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte of E0, expecting a 2nd byte between A0 and BF."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte of E0, expecting a 3nd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte of E0, expecting two following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 3
        }
        elseif ($hex_array[$i] -ge "0xE1" -and $hex_array[$i] -le "0xEC") # E1..EC 80..BF 80..BF */
        {
            if ($i + 2 -lt $hex_array_size) # Expect a 2nd and 3rd byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte between E1 and EC, expecting the 2nd byte between 80 and BF."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte between E1 and EC, expecting the 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte between E1 and EC, expecting two following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 3
        }
        elseif ($hex_array[$i] -eq "0xED") # ED 80..9F 80..BF */
        {
            if ($i + 2 -lt $hex_array_size) # Expect a 2nd and 3rd byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0x9F")
                {
                    $msg.value = "After a first byte of ED, expecting 2nd byte between 80 and 9F."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte of ED, expecting 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte of ED, expecting two following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 3
        }
        elseif ($hex_array[$i] -ge "0xEE" -and $hex_array[$i] -le "0xEF") # EE..EF 80..BF 80..BF */
        {
            if ($i + 2 -lt $hex_array_size) # Expect a 2nd and 3rd byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte between EE and EF, expecting 2nd byte between 80 and BF."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte between EE and EF, expecting 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte between EE and EF, two following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 3
        }
        elseif ($hex_array[$i] -eq "0xF0") # F0 90..BF 80..BF 80..BF */
        {
            if ($i + 3 -lt $hex_array_size) # Expect a 2nd, 3rd 3th byte */
            {
                if ($hex_array[$i + 1] -lt "0x90" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F0, expecting 2nd byte between 90 and BF."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F0, expecting 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
                if ($hex_array[$i + 3] -lt "0x80" -or $hex_array[$i + 3] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F0, expecting 4th byte between 80 and BF."
                    $faulty_bytes.value = 4
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte of F0, expecting three following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 4
        }
        elseif ($hex_array[$i] -ge "0xF1" -and $hex_array[$i] -le "0xF3") # F1..F3 80..BF 80..BF 80..BF */
        {

            if ($i + 3 -lt $hex_array_size) # Expect a 2nd, 3rd 3th byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F1, F2, or F3, expecting a 2nd byte between 80 and BF."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F1, F2, or F3, expecting a 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
                if ($hex_array[$i + 3] -lt "0x80" -or $hex_array[$i + 3] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F1, F2, or F3, expecting a 4th byte between 80 and BF."
                    $faulty_bytes.value = 4
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte of F1, F2, or F3, expecting three following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 4
        }
        elseif ($hex_array[$i] -eq "0xF4") # F4 80..8F 80..BF 80..BF */
        {
            if ($i + 3 -lt $hex_array_size) # Expect a 2nd, 3rd 3th byte */
            {
                if ($hex_array[$i + 1] -lt "0x80" -or $hex_array[$i + 1] -gt "0x8F")
                {
                    $msg.value = "After a first byte of F4, expecting 2nd byte between 80 and 8F."
                    $faulty_bytes.value = 2
                    return $false
                }
                if ($hex_array[$i + 2] -lt "0x80" -or $hex_array[$i + 2] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F4, expecting 3rd byte between 80 and BF."
                    $faulty_bytes.value = 3
                    return $false
                }
                if ($hex_array[$i + 3] -lt "0x80" -or $hex_array[$i + 3] -gt "0xBF")
                {
                    $msg.value = "After a first byte of F4, expecting 4th byte between 80 and BF."
                    $faulty_bytes.value = 4
                    return $false
                }
            }
            else
            {
                $msg.value = "After a first byte of F4, expecting three following bytes."
                $faulty_bytes.value = 1
                return $false
            }
            $i += 4
        }
        else
        {
            $msg.value = "Expecting bytes in the following ranges: 00..7F C2..F4."
            $faulty_bytes.value = 1
            return $false
        }
    }

    $msg.value = $null
    return $true
}

function Get-file-looks-utf8-with-BOM($file) {
    [Byte[]]$bom = Get-Content -Encoding Byte -ReadCount 4 -TotalCount 4 $file.Fullname
    return ($bom.length -gt 3 -And $bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf)
}

function Get_File_Looks_Ascii($file) {
    $nonPrintable = [char[]] (0..8 + 10..31 + 127 + 129 + 141 + 143 + 144 + 157)
    $lines = Get-Content $file.Fullname -ErrorAction Ignore -TotalCount 5
    $result = @($lines | Where-Object { $_.IndexOfAny($nonPrintable) -ge 0 })
    
    return ($result.Count -gt 0 -Or (Get-Item $file.Fullname).length -eq 0)
}