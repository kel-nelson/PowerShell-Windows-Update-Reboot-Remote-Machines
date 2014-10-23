Get-Content C:\server-configs\machine-list.txt | Foreach-Object { #for each computer

	$AutoUpdate = $false
	$AutoUpdateKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
	#Invoke-Command -ComputerName $_ -ScriptBlock {Test-Path -Path "$using:AutoUpdateKeyPath\RebootRequired"} |`
	$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $_ )
	Try
	{
		$RegKeys = $Reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
		Foreach($name in $RegKeys.GetValueNames())
		{
			If($RegKeys.GetValue($name) -eq $true) #found item that requires reboot
			{
				$AutoUpdate = $true
			}
		}
	}Catch
	{
		$_ + ": No Restart Required"
	}

	If($AutoUpdate)
	{
        	$_ + ": Restarting"
		%{Restart-computer –computername $_ –force; start-sleep -S 30}
	}
}
