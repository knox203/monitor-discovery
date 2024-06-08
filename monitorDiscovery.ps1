# Monitor Discovery v1.20230304
# This script discovers essential information on all active monitors connected to a computer
# knox203 - o7910n6oo@mozmail.com
##=====================================
# DEFAULTS:
# $debug = 1 to output the results to console and disable csv export
# $filename and $outputPath must be defined for the script to run
##=====================================
$debug = 1
$filename = "connectedMonitors.csv"
$outputPath = "C:\temp"
##=====================================
# Initialize variables and hash tables
##=====================================
$timeout = 10
$monitorNum = 1
$computerName = $env:computername
$bufferCsv = Join-Path $env:TEMP ($computerName + '-' + $filename)
$centralCsv = "$outputPath\$filename"
$lockFileID = "-$computerName.lock"
$lockFile = ($centralCsv + $lockFileID)
$monitorInfo = @()
$connections = @{}
$usbDevices = @{}
$ids = @{}
$dimensions = @{}
$inputTypeMap = @{
    0 = 'Analog'
    1 = 'Digital'
}
$connectorMappings = @{
    '-1' = 'Other'
    '0' = 'HD15'
    '1' = 'SVIDEO'
    '2' = 'Composite Video'
    '3' = 'Component Video'
    '4' = 'DVI'
    '5' = 'HDMI'
    '6' = 'LVDS'
    '8' = 'D JPN'
    '9' = 'SDI'
    '10' = 'DisplayPort External'
    '11' = 'DisplayPort Embedded'
    '12' = 'UDI External'
    '13' = 'UDI Embedded'
    '14' = 'SD TV Dongle'
    '15' = 'Miracast'
    '16' = 'Indirect Wired'
    '17' = 'Indirect Virtual'
    '18' = 'Virtual'
    '19' = 'Internal Wire'
    '20' = 'Other Display Technology'
    '2147483648' = 'Built-In Screen'
}
$monitorManufacturers = @{
    'ACI' = 'Ancor Communications Inc'
    'ACR' = 'Acer Technologies'
    'ALI' = 'Acer Labs'
    'ANX' = 'Acer Netxus Inc'
    'AOA' = 'AOpen Inc.'
    'AOC' = 'AOC International'
    'ADI' = 'ADI Systems Inc.'
    'AGI' = 'Agiea Corporation'
    'ARC' = 'ARC International'
    'AST' = 'AST Research Inc.'
    'APP' = 'Apple Inc.'
    'ASU' = 'ASUSTek Computer Inc.'
    'AUO' = 'Laptop/OEM Display'
    'AUS' = 'ASUSTek Computer Inc.'
    'BEN' = 'BenQ Corporation'
    'BOE' = 'Laptop/OEM Display (BOE)'
    'CHE' = 'Acer Inc'
    'CMN' = 'Laptop/OEM Display'
    'CMO' = 'Chi Mei Optoelectronics Corporation'
    'COM' = 'Compaq Computer Corp.'
    'CPT' = 'Chunghwa Picture Tubes Ltd.'
    'CRL' = 'Carroll Touch Inc.'
    'CTL' = 'CTL Corporation'
    'CTX' = 'CTX International Inc.'
    'DWE' = 'Datawind Inc.'
    'DEL' = 'Dell Inc.'
    'DLL' = 'Dell Inc'
    'ECI' = 'eColor Inc.'
    'EIZ' = 'EIZO Corporation'
    'EMI' = 'EMI Corporation'
    'EPI' = 'Envision Peripherals Inc.'
    'EXD' = 'eXtendMedia Inc.'
    'FSN' = 'Fujitsu Limited'
    'FUJ' = 'Fujitsu Ltd.'
    'GCC' = 'Gateway Computer Corp.'
    'GDM' = 'Sony Corporation'
    'GSM' = 'LG Display Co., Ltd.'
    'GVC' = 'GVC Corporation'
    'HAN' = 'Hansol Electronics Inc.'
    'HDC' = 'Laptop/OEM Display'
    'HIT' = 'Hitachi Ltd.'
    'HPC' = 'Hewlett-Packard Co.'
    'HPD' = 'Hewlett Packard'
    'HPE' = 'Hewlett Packard Enterprise'
    'HPN' = 'HP Inc.'
    'HPO' = 'Hewlett-Packard Co.'
    'HWP' = 'HP Inc.'
    'HWV' = 'Huawei Technologies Co., Inc.'
    'IBM' = 'International Business Machines Corp.'
    'ICL' = 'ICL Computers Ltd.'
    'IMA' = 'Iiyama North America Inc.'
    'IVM' = 'IvM Net BV'
    'KDS' = 'Korea Data Systems Co. Ltd.'
    'LCT' = 'Lite-On Technology Corporation'
    'LEN' = 'Lenovo'
    'LGD' = 'Laptop/OEM Display (LG)'
    'LGS' = 'LG Semicom Company Ltd'
    'LIN' = 'Lenovo Beijing Co. Ltd.'
    'LNV' = 'Lenovo'
    'LPL' = 'LG.Philips LCD Co., Ltd.'
    'MAG' = 'Mag Innovision Inc.'
    'MDO' = 'Panasonic'
    'MSG' = 'MSI GmbH'
    'MEI' = 'Panasonic Industry Company'
    'NCE' = 'Norcent Technology, Inc.'
    'NCS' = 'Northgate Computer Systems'
    'NEC' = 'NEC Corporation'
    'OQI' = 'OQI Corporation'
    'PBL' = 'Packard Bell Electronics'
    'PBN' = 'Packard Bell NEC'
    'PCA' = 'Philips BU Add On Card'
    'PCS' = 'TOSHIBA PERSONAL COMPUTER SYSTEM CORPRATION'
    'PEG' = 'Pegatron Corporation'
    'PHL' = 'Philips Electronics'
    'PHE' = 'Philips Medical Systems Boeblingen GmbH'
    'PHS' = 'Philips Communication Systems'
    'PSC' = 'Philips Semiconductors'
    'PIC' = 'Pioneer Corporation'
    'PNP' = 'Plug and Play'
    'PTC' = 'Planar Systems Inc.'
    'QUA' = 'Quanta Computer Inc.'
    'RRR' = 'Razer'
    'SAM' = 'Samsung Electronics Co., Ltd.'
    'SCT' = 'Sun Corporation'
    'SDC' = 'Laptop/OEM Display'
    'SEM' = 'Samsung Electronics Company Ltd'
    'SGL' = 'Seiko Epson Corporation'
    'SGX' = 'Silicon Graphics Inc'
    'SII' = 'Seiko Instruments Inc.'
    'SPT' = 'Sceptre Inc.'
    'SNY' = 'Sony Corporation'
    'SSC' = 'Shanghai SVA-NEC Liquid Crystal Display Co. Ltd.'
    'SSE' = 'Samsung Electronic Co.'
    'STN' = 'Samsung Electronics America'
    'SUM' = 'Summagraphics Corporation'
    'TAI' = 'Toshiba America Info Systems Inc'
    'TAT' = 'Tatung Company'
    'TEV' = 'Tencent'
    'TOS' = 'Toshiba Corporation'
    'TOT' = 'TOTOKU ELECTRIC CO., LTD.'
    'TRI' = 'Trigem Computer Inc.'
    'TSB' = 'Toshiba America Info Systems Inc'
    'TTP' = 'Toshiba Corporation'
    'TVM' = 'Tatung Company of America Inc.'
    'UNK' = 'Unknown'
    'VIT' = 'VIT Technology (Group) Inc.'
    'VIZ' = 'VIZIO Inc.'
    'VLV' = 'Valve Corporation'
    'VMW' = 'VMware Inc.,'
    'VSC' = 'ViewSonic Corporation'
    'WDC' = 'Western Digital Corporation'
    'WTF' = 'WTF Optronics Corporation'
    'WNX' = 'Diebold Nixdorf Systems GmbH'
    'XER' = 'Xerox Corporation'
    'ZOW' = 'ZOWIE Co., Ltd.'
}
# Define function to convert ManufacturerName and UserFriendlyName to ASCII
function Convert-Ascii ([byte[]]$bytes) {
    [System.Text.Encoding]::GetEncoding(437).GetString($bytes).TrimEnd([char]0)
}
# Define function to strip the input of all special characters and raise to upper-case for consistency
function Convert-Sanitized ([string]$instanceID) {
    ($instanceID -replace '\W|_0$', '').ToUpper()
}
# Define function to grab monitor manufacturer name from hash table from MonitorID string
function Get-MonitorManufacturer ([string]$DisplayID) {
    if ($DisplayID -like 'DISPLAY\*' -and $monitorManufacturers.ContainsKey($DisplayID.Substring(8, 3))) {
        return $monitorManufacturers[$DisplayID.Substring(8, 3)]
    }
    'Unknown'
}
function Wait-Timer ([int]$waitTime) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (Test-Path "$centralCsv-*.lock") {
        Write-Host "Waiting for the Central CSV file to become writeable..."
        Start-Sleep -Seconds 1
        if ($stopwatch.Elapsed.TotalSeconds -ge $waitTime) { Throw }
    }
    $true
}
# Define function to get the highest supported resolution
function Get-HighestResolution ([string]$monitor,[array]$supportedModes) {
    $mode = $supportedModes | Where-Object { Convert-Sanitized($_.InstanceName) -eq $monitor -and $_.MonitorSourceModes } | Select-Object -First 1
    if (!$mode) { return $null }
    $resolution = [PSCustomObject]@{
        Horizontal = ($mode.MonitorSourceModes | Where-Object HorizontalActivePixels).HorizontalActivePixels | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        Vertical = ($mode.MonitorSourceModes | Where-Object VerticalActivePixels).VerticalActivePixels | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        ModeID = Convert-Sanitized($mode.InstanceName)
    }
    $resolution
}
# Get computer information, otherwise output error and exit script
try {
    $computer = Get-CimInstance Win32_ComputerSystem -Property Manufacturer,Model -ErrorAction Stop
    $computerSN = Get-CimInstance Win32_SystemEnclosure -Property SerialNumber -ErrorAction Stop
    $lastUser = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI -Name LastLoggedOnSAMUser).LastLoggedOnSAMUser.Split('\')[-1]
}
catch {
    Write-Error "Error getting computer information: $($_.Exception.Message)"
    Exit 1
}
try {
    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction Stop
    $supportedModesArray = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorListedSupportedSourceModes -ErrorAction Stop
    Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams | ForEach-Object {
        $connections[$(Convert-Sanitized($_.InstanceName))] = $_
    }
    Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
        $ids[$(Convert-Sanitized($_.InstanceName))] = $_
    }
    # Identify USB-connected monitors
    Get-CimInstance CIM_DeviceConnection | 
        Where-Object { ($($_.CimClass).CimClassName -eq 'Win32_USBControllerDevice') -and ($($_.Dependent).DeviceID -like 'DISPLAY\*') } | ForEach-Object {
        $deviceID = Convert-Sanitized $($_.Dependent).DeviceID
        $usbDevices[$deviceID] = 1
    }
}
catch {
    Write-Error "Error getting monitor information: $($_.Exception.Message)"
    Exit 1
}
# Initialize loop variables and run
$monitors | ForEach-Object {
    $monitorInstance = $(Convert-Sanitized $_.InstanceName)
    $width = $_.MaxHorizontalImageSize
    $height = $_.MaxVerticalImageSize
    $diagonal = [math]::Sqrt($width * $width + $height * $height) / 2.54
    $monitorManufacturer = Get-MonitorManufacturer $ids["$monitorInstance"].InstanceName
    $monitorModel = Convert-Ascii $ids["$monitorInstance"].UserFriendlyName
    $monitorSerialNumber = Convert-Ascii $ids["$monitorInstance"].SerialNumberID
    $monitorConnection = $connections["$monitorInstance"].VideoOutputTechnology
    $resolution = Get-HighestResolution $monitorInstance $supportedModesArray
    $dimensions = [PSCustomObject]@{
        Width = $resolution.Horizontal
        Height = $resolution.Vertical
        ModeID = $resolution.ModeID
    }
    $inputType = $inputTypeMap[[int]$_.VideoInputType]
    # $external will be set to $false if any of the conditions below are met
    $external = !(
        ($monitorManufacturer -eq "Laptop/OEM Display") -or
        (@(6, 11, 13, 18, 19, 2147483648) -contains $monitorConnection -and !$usbDevices["$monitorInstance"]) -or
        ($computer.Model -match "AIO" -and ($computer.Model -replace " AIO",'') -eq $monitorModel)
    )
    $external = if ($external -eq 1) { 'Yes' } else { 'No' }
    # If Monitor Manufacturer result comes back as a laptop, set the model and SN to dashes
    $outputTech = $connectorMappings["$monitorConnection"]
    if($monitorManufacturer -eq "Laptop/OEM Display") {
        $monitorModel = "----------"
        $monitorSerialNumber = "----------"
    }
    # Mark USB-connected displays as such
    if ($usbDevices["$monitorInstance"]) {
        $connectorType = "USB"
    } else {
        $connectorType = "$outputTech ($inputType)"
    }
    $monitorInfo += [PSCustomObject]@{
        "Computer Name" = $computerName
        "Last User" = $lastUser
        "Computer Make" = $computer.Manufacturer
        "Computer Model" = $computer.Model
        "Computer Serial #" = $computerSN.SerialNumber
        "Monitor #" = $monitorNum++
        "Monitor Make" = $monitorManufacturer
        "Monitor Model" = $monitorModel
        "Monitor Serial #" = $monitorSerialNumber
        "Monitor Size" = [int]($diagonal + .4)
        "Maximum Resolution Width" = $dimensions.Width
        "Maximum Resolution Height" = $dimensions.Height
        "Connector Type" = $connectorType
        "External" = $external
        "MonitorID" = $_.InstanceName
        "Collected On" = Get-Date -UFormat "%D %H:%M:%S"
    }
}
# Output monitor information to console or central CSV file
if($debug) {
    $monitorInfo | Format-List
} else {
    # Write results to local buffer CSV
    $monitorInfo | Export-Csv -Path $bufferCsv -NoType -Force
    # Create lock on $centralCsv and wait for opportunity to write
    try {
        Wait-Timer $timeout | Out-Null
        $locked = New-Object IO.FileStream($lockFile, 'Create', 'Write', 'None')
        Import-Csv $bufferCsv | Export-Csv $centralCsv -NoType -Append
        Write-Host "Monitor information has been added to $centralCsv." -Fore Green
    }
    catch {
        $fallback = "$outputPath\Fallback Results\$computerName-$filename"
        Write-Warning "Failed to merge buffer CSV with central CSV. Outputting buffer CSV instead. File can be found at $fallback"
        Move-Item $bufferCsv $fallback -Force
        Exit 1
    }
    finally {
        $locked.Close()
        $locked.Dispose()
        if(Test-Path $lockFile) {
            Remove-Item $lockFile
        }
        Exit 0
    }
}
