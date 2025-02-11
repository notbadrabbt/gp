# gp.ps1

This PowerShell script is designed to kill GlobalProtect by stopping its associated process and service and then starting them again, when you are ready. 

It is intended to be used to restart a stuck client, since there is no way to do it via the agent.

## Features:
- **Stops the GlobalProtect process and service:**  
  Terminates the `pangpa` process and stops the `PanGPS` service.
- **Restarts GlobalProtect:**  
  After a short delay, the script starts the GlobalProtect service and launches the GlobalProtect client executable.
- **Admin Privilege Check:**  
  Automatically checks for administrator rights and attempts to elevate privileges if necessary.
- **Interactive and Automatic Modes:**  
  Use the `-restart` switch for an automatic restart (with a 5-second delay) or run without it for a manual prompt <`ENTER`> to restart GlobalProtect when ready.

## Prerequisites:
- **PowerShell:**  
  This script requires PowerShell to run.
- **Administrator Rights:**  
  Since the script manages services and processes, it must be run with administrative privileges.
- **GlobalProtect Installation:**  
  The script assumes GlobalProtect is installed in the default location:  
  `C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe`

## Usage:
### Automatic Restart
To automatically restart GlobalProtect after a 5-second delay: `.\gp.ps1 -restart`
### Interactive Mode:
To stop GlobalProtect and wait for user input before restarting: `.\gp.ps1
### Displaying Help:
For help information at runtime: `.\gp.ps1 -help
Alternatively, you can use PowerShell’s built-in help system: `Get-Help .\gp.ps1 -Detailed
### Logging:
All actions are logged to: C:\Temp\Logs\gp_log.txt 

## Author
[Conrad Culling](conradculling.com)  
[GitHub](github.com/notbadrabbt)

## License
This project is released under the Unlicense.

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more details, please visit [https://unlicense.org/](https://unlicense.org/).

## Contributing
Contributions, issues, and feature requests are welcome. If you have suggestions or improvements, please feel free to fork the repository and submit a pull request.

## Disclaimer
This script is provided as-is. Use it at your own risk; the author is not responsible for any damages or unintended consequences resulting from its use.
