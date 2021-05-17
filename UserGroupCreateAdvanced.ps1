# Make a function named CreateUserGroup to store each input and cmdlets 

function CreateUserGroup {

    # Create variable attempts as initializer 
    $trials = 3

    #BONUS MARKS: Do statement that loop to permits user to to input information 
    do {

        # Assign variable le000173_usr for user to input local host
        $le000173_usr = Read-Host "Please Enter name of host: "

        # Assign variable Password for user to input an encrypted password 
        $Password = Read-Host -AsSecureString 

        # Assign variable le000173_grp for user to input name of new local group
        $le000173_grp = Read-Host "Please enter name of group: "

        # create variables localuser and localgroup to store cmdlets that looks for prompted names
        $localuser = Get-LocalUser $le000173_usr 2> $null

        $localgroup = Get-LocalGroup $le000173_grp 2> $null

        # Conditonal statement indicates that if username already exists in localgroup, which is true, then inform user it already exists
        if ($le000173_usr -eq $localuser){

            Write-Host "$le000173_usr already exists!"  

            $new_user = Read-Host "Would you like to create another username? Y/N"

            # exit script if input is "N"
            if ($new_user -eq "N"){

                Write-Host "Press any key to continue..."
                
                exit 
           
            }
            
        }else { 
    
            New-LocalUser -Name $le000173_usr -Description "User Example" -Password $Password 2> $null
    
            Write-Host "$le000173_usr was created !!!"
        
        }

        # Similar condition as above, but checks group name already exists 
        if ($le000173_grp -eq $localgroup){

             Write-Host "$le000173_grp already exists !"

        }else {
    
            New-LocalGroup -Name $le000173_grp -Description "Local Group Example" 2> $null

            Write-Host "$le000173_grp was created !"

        }

        # Each time the do statement that loop is executed, the value of trials increases by 1 
        $trials--

        Write-Host "Attempts: $trials"

        # Add created user to localgroup
        Add-LocalGroupMember -Group $le000173_grp -Member $le000173_usr

        # Make User home folder using usr variable
        Write-Host "Creating folder $le000173_usr in local disk" 2> $null
    
        # Assign variable for path for new folder 
        $HOMEDIR = "C:\$le000173_usr"

        # Making a new folder using user name
        New-Item -PATH $HOMEDIR -ItemType Directory 2> $null

        $Share_Name = -Join ($le000173_usr , "-Share") 

        # Create Share using the username 
        New-SmbShare -Name $le000173_usr-Share -Path $HOMEDIR 2> $null

        # Asks the user to give a drive letter to map a drive
        $Drive_Map = Read-Host "Please assign a drive letter for shared drive: "

        #Verify if there is an existing drive letter 
        $Mapped_Drive = Get-PSDrive -Name "$Drive_Map" 2> $null

        if ($Drive_Map -eq $Mapped_Drive){

            Write-Host "Drive $Drive_Map already exists !"
    
            # Inform user if they want to remove the drive
            $remove_disk = Read-Host "Would you like to remove $Drive_Map? Y/N "
    
            if ( $remove_disk -eq "Y") {
    
                Remove-PSDrive $Drive_Map
    
            }
    
        }else {
    
            New-PSDrive -Name $Drive_Map -PSProvider FileSystem -Root "\\$env:COMPUTERNAME\$Share_Name" 
    
            Write-Host "Made shared folder in Drive $Drive_Map" 
    
        }

        # Add user permission of new user with shared folder
        Grant-SmbShareAccess -name $Share_Name -AccountName $le000173_usr -AccessRight Full

        # Add group permssion of new group with shared folder
        Grant-SmbShareAccess -name $Share_Name -AccessName $le000173_grp -AccessRight Control

    # Condition loops only if user inputs Y and if number of trials is less or equal to 3
    } while ($new_user -eq "Y" -And $trials -ge 0)
   
}

# Do statement that loops to provide an option to either run the function CreateUserGroup again or exit 
do{

    CreateUserGroup
    $repeat = Read-Host "Do you wish to run the script again? Y/N"

    if ($repeat -eq "N"){

        Write-Host "End of script !"

    }

} while ($repeat -eq "Y")