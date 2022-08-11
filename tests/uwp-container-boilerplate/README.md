# UWP Container Boilerplate
Microsoft is increasing the security of the Windows platform. Features such as named pipes are disabled on generic executables, and only enabled when packaged as a uwp container.

## How to use this Boilerplate
1. Replace the GNUstepUWPTest.exe.stub with a real executable and rename it to `GNUstepUWPTest.exe`.
   **Note:** UWP applications only search in `C:\Windows\System32` for dlls. I have yet to find a way to include dlls in UWP applications. For now, just copy all required dlls over into the System32 directory (Don't forget to delete them once you're finished).
2. Enable the Windows developer mode
3. Execute `Add-AppxPackage –Register AppxManifest.xml` in a Windows Powershell
4. Open `GNUstepUWPTest` from Windows Start
