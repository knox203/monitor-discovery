
# Monitor Discovery v1.20230304

This script discovers essential information on all active monitors connected to a computer and can output the results to a console or a CSV file. It is designed to run on a single machine locally or be deployed across an array of computers within a LAN. When deployed in a network, it can write to a central CSV file if the location is configured to a UNC path.

## Features

- Discovers and lists detailed information about all active monitors connected to the computer.
- Outputs the results to the console (in debug mode) or a CSV file.
- Can be configured to write results to a central CSV file in a network environment.
- Includes detailed information about the computer, monitors, and their connections.

## Default Settings

- **Debug Mode:** Enabled (outputs results to the console and disables CSV export).
- **CSV Filename:** `connectedMonitors.csv`
- **Output Path:** `C:\temp`
- **Timeout:** 10 seconds
- **Monitor Numbering:** Starts at 1

## Configuration

You can change the behavior of the script by modifying the following variables:

### $debug

- **Description:** Controls whether the results are output to the console or exported to a CSV file.
- **Default Value:** `1`
- **Options:** 
  - `1` - Output to console and disable CSV export.
  - `0` - Export results to a CSV file.

### $filename

- **Description:** The name of the CSV file to which the results will be exported.
- **Default Value:** `connectedMonitors.csv`
- **Options:** Any valid filename string.

### $outputPath

- **Description:** The directory path where the CSV file will be saved.
- **Default Value:** `C:\temp`
- **Options:** Any valid directory path string. This can be a UNC path for network deployments.

### $timeout

- **Description:** The timeout period for waiting to write to the central CSV file.
- **Default Value:** `10` seconds
- **Options:** Any integer value representing seconds.

## How to Use

1. **Run Locally:**
   - Simply run the script on a local machine. The results will be displayed in the console (default debug mode) or exported to the specified CSV file if `$debug` is set to `0`.

2. **Deploy in a Network:**
   - Configure `$outputPath` to a UNC path where the central CSV file will be stored.
   - Deploy the script across multiple machines in the LAN using your preferred deployment method (e.g., Group Policy, login scripts).
   - Ensure the central CSV file is accessible and writable by all machines.

## Example Usage

1. **Local Execution (Debug Mode):**
   ```powershell
   .\MonitorDiscovery.ps1
   ```

2. **Local Execution (CSV Export):**
   ```powershell
   $debug = 0
   .\MonitorDiscovery.ps1
   ```

3. **Network Deployment (CSV Export to Central Location):**
   ```powershell
   $debug = 0
   $outputPath = "\\network\share\path"
   .\MonitorDiscovery.ps1
   ```

## Error Handling

- The script includes error handling for retrieving computer and monitor information.
- If an error occurs, the script will output an error message and exit.
- If the script fails to merge the buffer CSV with the central CSV, it will output the buffer CSV to a fallback location and provide a warning message.

## Contact

For any questions or issues, please contact the script author:
- **knox203**
- **Email:** [o7910n6oo@mozmail.com](mailto:o7910n6oo@mozmail.com)
