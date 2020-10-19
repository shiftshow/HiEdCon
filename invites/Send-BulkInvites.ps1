Import-Module -Name AzureAD
Import-Module -Name MicrosoftTeams
Connect-AzureAD
Connect-MicrosoftTeams

#Enter the display name of your team
$TeamDisplayName = 'My Conf Team'
$GroupId = (Get-Team -DisplayName $TeamDisplayName).GroupId

$Invitations = Import-Csv -Path '.\BulkInviteUsers.csv'
#$Invitations | Select-Object -First 5

#Text that will appear in the invite email
$InviteMsg = 'Hi, attendee. Please click Accept invitation to setup your Guest Account to access the conference venue. You can find more information at: https://aka.my/conf2020info'
#Upon succussful invite acceptance, redirect the user to this location (link to team including tenantId parameter).
$InviteRedirectUrl = 'https://aka.my/conf2020team'

####### Main Code #######
$RunTime = Get-Date -Format 'yyyyMMdd-HHmmss'
#Create an output file to collect invites
$InvitedFile = ".\InvitedUserIds_$($RunTime).csv"
'DisplayName, EmailAddress, UserId, Status' | Out-File $InvitedFile -Force -Append

$MessageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$messageInfo.customizedMessageBody = $InviteMsg

#Generate initial invites
foreach ($email in $Invitations) {
    $Params = @{
        InvitedUserEmailAddress = $email.EmailAddress;
        InvitedUserDisplayName  = $email.DisplayName;
        InviteRedirectUrl       = $InviteRedirectUrl;
        InvitedUserMessageInfo  = $MessageInfo;
        SendInvitationMessage   = $true;
        InvitedUserType         = 'Guest';
    }
    $Params2 = @{
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

#Add invited users to the team
$NewMembers = Import-Csv $InvitedFile
$NewMembers | Where-Object { $_.Status -ne "FAILED" } | 
    ForEach-Object { 
        Add-TeamUser -GroupId $GroupId -User $_.UserId -Role Member
    }


