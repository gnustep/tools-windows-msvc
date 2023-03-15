#!/bin/sh

# Copy mdns stuff into the folders so GNUstep can build with them...
cp ./dependencies/bin/dnssd.dll /c/GNUstep/x64/Debug/bin
cp ./dependencies/bin/dnssd.dll /c/GNUstep/x64/Debug/bin/dns_sd.dll
cp ./dependencies/lib/dnssd.lib /c/GNUstep/x64/Debug/lib
cp ./dependencies/lib/dnssd.lib /c/GNUstep/x64/Debug/lib/dns_sd.lib
cp ./dependencies/include/dns_sd.h /c/GNUstep/x64/Debug/include

# Release
cp ./dependencies/bin/dnssd.dll /c/GNUstep/x64/Release/bin
cp ./dependencies/bin/dnssd.dll /c/GNUstep/x64/Release/bin/dns_sd.dll
cp ./dependencies/lib/dnssd.lib /c/GNUstep/x64/Release/lib
cp ./dependencies/lib/dnssd.lib /c/GNUstep/x64/Release/lib/dns_sd.lib
cp ./dependencies/include/dns_sd.h /c/GNUstep/x64/Release/include
