#To test the script uncomment line 24 - this will create a folder structure 

#Replace string "pwshrename" with a folder where input csv file exists
$work_dir = Join-Path -Path $env:SystemDrive -ChildPath "pwshrename"

#This is where users have their folders
$users_dir = Join-Path -Path $work_dir -ChildPath "users"

# This is helper function that creates a folder structure to test
function Create-Folder
{
    
    $users = "Aasa, Cheryl 020387 082518","Ababat, Wenifredo 013162 011621","Aballi, Taylor 011591 081219","Abarca-roman, Fernando 071993 061921","Abaya, Brenda 122357 081419"
    $users | ForEach-Object {
        if (!(Test-Path $(join-path -Path $users_dir -ChildPath $_)))
        {
            Write-Host "Creating folder $users_dir\$_"
            New-Item -Path $users_dir -Name $_ -ItemType Directory
        }
    }
}

# Execution of function - required to create a testing environment
#Create-Folder

#importing a csv file with ACCT data to variable
$imported_users = Import-Csv "$work_dir\input.csv"

Get-ChildItem $users_dir -Directory | select -ExpandProperty name | ForEach-Object {
    #Assigning variables based on folder name
    $dir_first = $_.split(" ")[1]
    $dir_last = $_.split(" ")[0].replace(",","")
    $dir_last_svc = $_.split(" ")[3]
    $dir_acct = $_.split(" ")[-1]
    
    $acct = $null

    #Getting ACCT value from imported file based on folder variables
    $acct = $imported_users | Where-Object {$_.Last -eq $dir_last -and $_.First -eq $dir_first -and $_.Last_svc -eq $dir_last_svc} | select -ExpandProperty acct
    
    $old_folder_name = "$users_dir\$_"
    $new_folder_name = $_+" "+$acct
    write-host "Old folder name: `"$old_folder_name`"" -ForegroundColor Cyan
    if ($acct -and $dir_acct -ne $acct)
    {
        
        Write-Host "New folder name: `"$users_dir\$new_folder_name.`"" -ForegroundColor Cyan
        try
        {
            Rename-Item -Path "$old_folder_name" -NewName $new_folder_name -ErrorAction 'Stop'
        }
        catch
        {
            Write-Host "Error renaming `"$old_folder_name.`". $_" -ForegroundColor Red
        }
        finally
        {
            if (Test-Path "$users_dir\$new_folder_name")
            {
                Write-Host "Rename completed." -ForegroundColor Cyan
            }
        }
    }
    else
    {
        Write-Host "Not renaming a folder `"$old_folder_name.`"" -ForegroundColor Cyan
    }

     $dir_first = $null
     $dir_last = $null
     $dir_last_svc = $Null
}

