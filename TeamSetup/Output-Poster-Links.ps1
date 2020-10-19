$links = @"
"Title","URL"
"📰 Poster01","https://teams.microsoft.com/l/channel/19%3fa2b4dd645dcc40159efe308a881fcb69%40thread.tacv2/%25F0%259F%2593%25B0%2520Poster01?groupId=b853de24-a34c-4026-94eb-87fd81bfc91f&tenantId=0d4da0f8-4531-4d76-ace6-0a62331e1b84"
"📰 Poster02","https://teams.microsoft.com/l/channel/19%3a0cb8cd0fdfbc445889748a31035bf336%40thread.tacv2/%25F0%259F%2593%25B0%2520Poster02?groupId=b853de24-a34c-4026-94eb-87fd81bfc91f&tenantId=0d4da0f8-4531-4d76-ace6-0a62331e1b84"
"📰 Poster03","https://teams.microsoft.com/l/channel/19%3da18f54e5bbab41278b030ed188812a58%40thread.tacv2/%25F0%259F%2593%25B0%2520Poster03?groupId=b853de24-a34c-4026-94eb-87fd81bfc91f&tenantId=0d4da0f8-4531-4d76-ace6-0a62331e1b84"
"📰 Poster04","https://teams.microsoft.com/l/channel/19%3a180ecc3a3ab44c22bc76dd388698bc56%40thread.tacv2/%25F0%259F%2593%25B0%2520Poster04?groupId=b853de24-a34c-4026-94eb-87fd81bfc91f&tenantId=0d4da0f8-4531-4d76-ace6-0a62331e1b84"
"📰 Poster05","https://teams.microsoft.com/l/channel/19%3aeaf72b39e2f34e6bb77c5be161960faf%40thread.tacv2/%25F0%259F%2593%25B0%2520Poster05?groupId=b853de24-a34c-4026-94eb-87fd81bfc91f&tenantId=0d4da0f8-4531-4d76-ace6-0a62331e1b84"
"@
$linkdatas = $links | ConvertFrom-Csv
foreach ($linkdata in $linkdatas) {
    Write-Output "<a href='$($linkdata.URL)'>$($linkdata.Title)</a></br>"
}