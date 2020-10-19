## Get invite status and generate new file for invites in pending status
Import-Module -Name AzureAD
Connect-AzureAD

$RecentInvites = '.\PendingStatusUpdated.csv'

####### Main Code #######
$RunTime = Get-Date -Format 'yyyyMMdd-HHmmss'
$InvitedFileStatus = ".\InvitedUserIdsStatus_$($RunTime).csv"
$PendingStatus = ".\PendingAcceptance_$($RunTime).csv"
'DisplayName, EmailAddress, UserId, Status' | Out-File $InvitedFileStatus -Force -Append
'DisplayName, EmailAddress, UserId, Status' | Out-File $PendingStatus -Force -Append

$MemberInvites = Import-Csv -Path $RecentInvites
#$MemberInvites | select -First 5

$MemberInvites | Where-Object { $_.Status -ne "Accepted" } | 
    ForEach-Object { 
        $InviteStatus = Get-AzureADUser -ObjectId $_.UserId
        "$($_.DisplayName),$($_.EmailAddress),$($_.UserId),$($InviteStatus.UserState)" |
            Out-File $InvitedFileStatus -Force -Append
        if ($InviteStatus.UserState -eq 'PendingAcceptance') {
            "$($_.DisplayName),$($_.EmailAddress),$($_.UserId),$($InviteStatus.UserState)" |
                Out-File $PendingStatus -Force -Append
        }
    }


$Status = Import-Csv -Path $InvitedFileStatus
$Status | Group-Object Status | Select-Object Count,Name


$MemberInvites | Where-Object { $_.Status -ne "FAILED" } | 
    ForEach-Object { 
        $InviteStatus = Get-AzureADUser -ObjectId $_.UserId
        if ($InviteStatus.UserState -eq 'PendingAcceptance') {
            "$($_.DisplayName),$($_.EmailAddress),$($_.InvitedUser.Id),$($InviteStatus.UserState)" |
                Out-File ".\PendingAcceptance_$($RunTime).csv" -Force -Append
        }
    }
