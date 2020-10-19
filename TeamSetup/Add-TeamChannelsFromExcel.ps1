#Install-Module -Name MicrosoftTeams
#Install-Module -Name ImportExcel

#Name of the team you are modifying
$TeamName = 'My Conference 2020'

#Import CSV of the Team channel, descriptions, emoji, and breakout quantity
#Header row = DisplayName, Description, Emoji, BreakoutQty
$ChannelFile = '.\TeamChannelTemplate1.xlsx'

Import-Module -Name MicrosoftTeams
Import-Module -Name ImportExcel
#$cred = Get-Credential -Message 'Enter your user account'
Connect-MicrosoftTeams

#Setup code to support removing special chars from Team name
#New Channel display name. Names must be 50 characters or less, and can't contain the characters # % & * { } / \ : < > ?
[char[]]$replaceChannel = '~#%&*{}+/\:<>?|''"'
#need to worry about underscore and period as first char, period as last char, and 2 periods together

$regex = ($replaceChannel | ForEach-Object { [regex]::Escape($_) }) -join '|'

$GroupId = (Get-Team -DisplayName $TeamName).GroupId

$Channels = Import-Excel -Path $ChannelFile

#Sanity check
$TotalChannels = 1 + ($Channels | Measure-Object 'BreakoutQty' -Sum).Sum + $Channels.Count - ($Channels | Where-Object 'BreakoutQty' -ne $null).count
if ($TotalChannels -gt 200) {
    throw "More than 200 total channels! ($TotalChannels)"
}

#Start creating the channels
#First will create channel without emoji, then renames to include emoji - keeps SPO links free of emoji characters.
#Breakout channels: If < 100 then "Channel##"; If > 100, then "Channel###"
foreach ($Channel in $Channels) {
    $ChannelName = ''
    $NewChannelName = ''
    $NewChannelRoot = ''
	$ChannelBrkOName = ''
	$ChannelNewName = ''
    #Strip bad characters from channel name
    Write-Output "------------"
    Write-Output "Working on channel: $($Channel.DisplayName)"
    $ChannelName = ($Channel.DisplayName -replace $regex, '-').Trim('-')
    if ($ChannelName -ne $Channel.DisplayName) {
        Write-Output "Channel name changed from $($Channel.DisplayName) to: $ChannelName"
    }
    if (($Channel.BreakoutQty -le 0) -or ($null -eq $Channel.BreakoutQty)) {
        New-TeamChannel -GroupId $GroupId -DisplayName $ChannelName -Description $Channel.Description
        if ($null -ne $Channel.emoji) {
            $NewChannelName = "$($Channel.emoji) $($ChannelName)"
            Set-TeamChannel -GroupId $GroupId -CurrentDisplayName $ChannelName -NewDisplayName $NewChannelName
        }
    } elseif ($Channel.BreakoutQty -gt 0) {
        if ($Channel.BreakoutQty -le 99) {
            1..$Channel.BreakoutQty |
                ForEach-Object {
					$ChannelBrkOName = "$ChannelName" + ("{0:D2}" -f $_)
                    New-TeamChannel -GroupId $GroupId -DisplayName $ChannelBrkOName
                }
            if ($null -ne $Channel.emoji) {
                $NewChannelRoot = "$($Channel.emoji) $($ChannelName)"
				Start-Sleep -Seconds 5
				1..$Channel.BreakoutQty |
					ForEach-Object {
						$ChannelBrkOName = "$ChannelName" + ("{0:D2}" -f $_)
						$ChannelNewName = "$NewChannelRoot" + ("{0:D2}" -f $_)
						Set-TeamChannel -GroupId $GroupId -CurrentDisplayName $ChannelBrkOName -NewDisplayName $ChannelNewName
					}
            }
        } elseif ( ($Channel.BreakoutQty -le 199) -and ($Channel.BreakoutQty -ge 100)) {
            1..$Channel.BreakoutQty |
                ForEach-Object {
					$ChannelBrkOName = "$ChannelName" + ("{0:D3}" -f $_)
                    New-TeamChannel -GroupId $GroupId -DisplayName $ChannelBrkOName
                }
            if ($null -ne $Channel.emoji) {
                $NewChannelRoot = "$($Channel.emoji) $($ChannelName)"
				Start-Sleep -Seconds 5
				1..$Channel.BreakoutQty |
					ForEach-Object {
						$ChannelBrkOName = "$ChannelName" + ("{0:D3}" -f $_)
						$ChannelNewName = "$NewChannelRoot" + ("{0:D3}" -f $_)
						Set-TeamChannel -GroupId $GroupId -CurrentDisplayName $ChannelBrkOName -NewDisplayName $ChannelNewName
					}
            }
        } else {
            Write-Output "Too many breakout channels requested!"
        }
    }
}

