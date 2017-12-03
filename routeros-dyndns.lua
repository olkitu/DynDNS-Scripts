# Set needed variables
:local username "theddnsusername"
:local password "theddnspassword"
:local hostname "dyndnsurl"
:local updateurl "updateurl"

:global dyndnsForce
:global previousIP
 
# print some debug info 
:log info ("UpdateDynDNS: username = $username")
:log info ("UpdateDynDNS: hostname = $hostname")
:log info ("UpdateDynDNS: previousIP = $previousIP")
 
# get the current IP address from the internet (in case of double-nat)
/tool fetch mode=http address="checkip.dyndns.org" src-path="/" dst-path="/dyndns.checkip.html"
:local result [/file get dyndns.checkip.html contents]
 
# parse the current IP result
:local resultLen [:len $result]
:local startLoc [:find $result ": " -1]
:set startLoc ($startLoc + 2)
:local endLoc [:find $result "</body>" -1]
:local currentIP [:pick $result $startLoc $endLoc]
:log info "UpdateDynDNS: currentIP = $currentIP"

# Remove the # on next line to force an update every single time - useful for debugging, but you could end up getting blacklisted by DynDNS!
#:set dyndnsForce true
 
# Determine if dyndns update is needed
# more dyndns updater request details available at http://www.dyndns.com/developers/specs/syntax.html
:if (($currentIP != $previousIP) || ($dyndnsForce = true)) do={
	:set dyndnsForce false
	:set previousIP $currentIP
    /tool fetch user=$username password=$password mode=http address=$updateurl  host=$updateurl  src-path="/nic/update\?hostname=$hostname&myip=$currentIP" dst-path="/dyndns.txt"
    :local result [/file get dyndns.txt contents]
    :log info ("UpdateDynDNS: Dyndns update needed")
    :log info ("UpdateDynDNS: Dyndns Update Result: ".$result)
    :put ("Dyndns Update Result: ".$result)
 } else={
    :log info ("UpdateDynDNS: No dyndns update needed")
 }