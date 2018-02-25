# Set required parameters
$hostname = "hostname"
$user = "username"
$pwd = "password"
$updateurl = "updateurl"

$pair = "$($user):$($pwd)"


#Get your current IP-address.
$url = "https://{0}/nic/checkip" -f $updateurl
$MyIpPage = Invoke-WebRequest -Uri $url

#Make sure we got a IP back in the response
If ($MyIpPage.RawContent -match "(?:[0-9]{1,3}.){3}[0-9]{1,3}")
{
    #encode the username and password for the header
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)

    $basicAuthValue = "Basic $base64"

    $headers = @{ Authorization =  $basicAuthValue }

    #Build up the URL
    $url = "https://{0}/nic/update?hostname={1}&myip={2}" -f $updateurl, $hostname, $MyIpPage

    #Invoke the URL
    $resp = Invoke-WebRequest -Uri $url -Headers $headers
    $resp.Content #Expected answers that I found "good","nochg","nohost","badauth","notfqdn"
}
Else
{
 #fake response if we didn't get any IP
 "No IP"
}