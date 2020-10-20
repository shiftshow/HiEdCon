Import-Module -Name AzureAD
Import-Module -Name MicrosoftTeams
Connect-AzureAD
Connect-MicrosoftTeams

$TeamDisplayName = 'My Conf Team'
$GroupId = (Get-Team -DisplayName $TeamDisplayName).GroupId

$Invitations = Import-Csv -Path '.\PendingAcceptance.csv'
#$Invitations | Select-Object -First 5

#Upon successful invite acceptance, redirect the user to this location (link to team including tenantId parameter).
$InviteRedirectUrl = 'https://aka.my/conf2020team'

####### Main Code #######
$RunTime = Get-Date -Format 'yyyyMMdd-HHmmss'
$InvitedFile = ".\ReInvitedUserIds_$($RunTime).csv"
'DisplayName, EmailAddress, UserId, Status' | Out-File $InvitedFile -Force -Append

#Resend invites
foreach ($email in $Invitations) {
    $Params = @{
        InvitedUserEmailAddress = $email.EmailAddress;
        InviteRedirectUrl       = $InviteRedirectUrl;
        SendInvitationMessage   = $true;
    }
    try {
        Write-Output "Inviting: $($email.EmailAddress)"
        $NewInvite = New-AzureADMSInvitation @Params
        "$($email.DisplayName),$($email.EmailAddress),$($NewInvite.InvitedUser.Id),$($NewInvite.Status)" |
            Out-File $InvitedFile -Force -Append
    }
    catch {
        Write-Output "Error inviting: $($email.EmailAddress)"
        "$($email.DisplayName),$($email.EmailAddress),,FAILED" | Out-File $InvitedFile -Force -Append
    }
}
