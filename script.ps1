# Chloe Jo
# Password Expiration Notifier
# July 25th - August 11, 2023
############################################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$FormObject=[System.Windows.Forms.Form] # Bring the form
$ButtonObject = [System.Windows.Forms.Button]
$LabelObject = [System.Windows.Forms.Label]

### Create GUI form
$PwReminder = New-Object $FormObject
$PwReminder.ClientSize = '670, 200'
$PwReminder.Text = "Password Expiration Date Reminder"
$PwReminder.BackColor="#ffffff"

# Label: User Name
$labelUser = New-Object $LabelObject
$labelUser.Text = "User Name: "
$labelUser.AutoSize=$true
$labelUser.Font='Verdana,10'
$labelUser.Location=New-Object System.Drawing.Point(70,30)

# Display the user's full name
$userFullName=New-Object $LabelObject
$userFullName.AutoSize=$true
$userFullName.Font='Verdana,10'
$userFullName.Location=New-Object System.Drawing.Point(270,30)

# Label: Expiry Date
$labelExpiryDate=New-Object $LabelObject
$labelExpiryDate.Text="Password Expiration Date: "
$labelExpiryDate.AutoSize=$true
$labelExpiryDate.Font='Verdana,10'
$labelExpiryDate.Location=New-Object System.Drawing.Point(70, 50)

# Display the user's expiry date
$userExpiryDate=New-Object $LabelObject
$userExpiryDate.AutoSize=$true
$userExpiryDate.Font='Verdana,10'
$userExpiryDate.Location=New-Object System.Drawing.Point(270, 50)

# Reminder
# Dates left = 14 days
$txtReminder1 = New-Object $LabelObject
$txtReminder1.AutoSize=$true
$txtReminder1.Font='Verdana,10'
$txtReminder1.Location=New-Object System.Drawing.Point(70,100)

# Dates left < 14 days
$txtReminder2 = New-Object $LabelObject
$txtReminder2.AutoSize=$true
$txtReminder2.Font='Verdana,10'
$txtReminder2.Location=New-Object System.Drawing.Point(70,100)

# Dates left < 2 days
$txtReminder3 = New-Object $LabelObject
$txtReminder3.AutoSize=$true
$txtReminder3.Font='Verdana,10'
$txtReminder3.Location=New-Object System.Drawing.Point(70,100)

# Add Okay Button to close the pop-up window
$btnOkay=New-Object $ButtonObject
$btnOkay.Text="OK"
$btnOkay.AutoSize=$true
$btnOkay.Location=New-Object System.Drawing.Point(290,170)

function ClickOkay
{
    $PwReminder.Close()
}

$btnOkay.Add_click({ClickOkay})

### Pull the password expiration data of all users only when the user is connected to the server using the try and catch block
Try # Try something that could cause an error
{
    $users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} `
    -Properties "Name", "msDS-UserPasswordExpiryTimeComputed" | ` Select-Object -Property "Name", `
    @{Name = "ExpiryDate"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
}
Catch # Catch any error
{
    Write-Host "Error"
    exit
}

### Get the user's full name
$userName = (whoami).Split('\')[1] # Get the user's account name
$userDisplayName = Get-AdUser -Identity $userName -Properties * # Get the user's name data

### Get the current date
$currentDate = (Get-Date)

### Calculate the number of days left until the password expires and tell the user when it expires
foreach($user in $users)
{ 
    $userFullName.Text= $user.Name
    $userExpiryDate.Text = $user.ExpiryDate
    
    # $userDisplayName.CN is used to pull the user's full name only
   if($userDisplayName.CN -eq $user.Name -and  $userDisplayName -ne "More Info" -and $userDisplayName.CN -ne "informix" -and $userDisplayName.CN -ne "PS Access")
{
   # Calculate the number of days left until the password expires
       $diff = (New-TimeSpan -start $currentDate -end $user.ExpiryDate).Days
       if($diff -eq 14) # Display if the user's password expires in 14 days
       {
            $txtReminder1.Text = "Your password expires in 14 days.`nPress ctrl + alt + del to change the password on your computer and sign in `nto Outlook on your phone after changing it."
       }
       elseif($diff -lt 14) # Display if the user's password expires in less than 14 days
       {
            $txtReminder2.Text = "You have only $diff days until your password expires.`nPress ctrl + alt + del to change the password on your computer and sign in to `nOutlook on your phone after changing it."
       }
       elseif($diff -lt 2) # Display if the user's password expires in less than 2 days and let them change their password now
       {
            $txtReminder3.Text = "If you don't change your password now, your account will be locked.`nPress ctrl + alt + del to change the password on your computer and sign in to `nOutlook on your phone after changing it."
       }
       else
       {
            #Test#$txtReminder1.Text = "Your password expires in 14 days.`nPress ctrl + alt + del to change the password on your computer and sign in `nto Outlook on your phone after changing it."
            #Test#$txtReminder2.Text = "You have only $diff days until your password expires.`nPress ctrl + alt + del to change the password on your computer and sign in to `nOutlook on your phone after changing it."
            #Test#$txtReminder3.Text = "If you don't change your password now, your account will be locked.`nPress ctrl + alt + del to change the password on your computer and sign in to `nOutlook on your phone after changing it."
        }
   break;
}
}

### Display all the GUI objects 
$PwReminder.Controls.AddRange(@($labelUser, $userFullName, $labelExpiryDate, $userExpiryDate, $txtReminder1, $txtReminder2, $txtReminder3, $btnOkay))
$PwReminder.ShowDialog()
$PwReminder.Dispose()