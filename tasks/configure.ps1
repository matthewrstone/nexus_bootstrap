
choco install nexus-repository -y

$tempPw = (Get-Content C:\ProgramData\sonatype-work\nexus3\admin.password).ToString()
$repo = "choco"


# Open the firewall
netsh advfirewall firewall add rule name="Nexus" dir=in action=allow protocol=TCP localport=8081

# Nexus disables scripts by default. This will open it up.
Write-Output "nexus.scripts.allowCreation=true" | Out-File C:\ProgramData\sonatype-work\nexus3\etc\nexus.properties -Encoding Ascii -Force

Restart-Service Nexus
Start-Sleep -Seconds 60

### INSTALL CHOCO REPO ###
choco install chocolatey-nexus-repo --version 1.0.0 --params="'/username=admin /password=$tempPw /repositoryname=$repo'"

### API KEY
$credPair = "admin:${tempPw}"
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))

$header = @{
    Authorization = "Basic $encodedCredentials"
}

$content = @"
import org.sonatype.nexus.security.authc.apikey.ApiKeyStore
import org.sonatype.nexus.security.realm.RealmManager
import org.apache.shiro.subject.SimplePrincipalCollection
def getOrCreateNuGetApiKey(String userName) {
    realmName = "NexusAuthenticatingRealm"
    apiKeyDomain = "NuGetApiKey"
    principal = new SimplePrincipalCollection(userName, realmName)
    keyStore = container.lookup(ApiKeyStore.class.getName())
    apiKey = keyStore.getApiKey(apiKeyDomain, principal)
    if (apiKey == null) {
        apiKey = keyStore.createApiKey(apiKeyDomain, principal)
    }
    return apiKey.toString()
}
getOrCreateNuGetApiKey("admin")
"@

$body = @{
    name    = "apikey"
    type    = "groovy"
    content = $content
}

Invoke-RestMethod -Uri "http://localhost:8081/service/rest/v1/script" -ContentType 'application/json' -Body $($body | ConvertTo-Json) -Header $header -Method Post
$result = Invoke-RestMethod -Uri "http://localhost:8081/service/rest/v1/script/apikey/run" -ContentType 'text/plain' -Header $header -Method Post
$result.result | Out-File C:\my_api_key.txt -Encoding Ascii -Force
$tempPw | Out-File C:\my_nexus_pw.txt -Encoding Ascii -Force

return @{
    password = $tempPw
    apikey = $result.result
} | ConvertTo-Json